import csv
import json
import re
import sys
from pathlib import Path

def read_json_metrics(json_path: Path):
    with json_path.open('r', encoding='utf-8') as f:
        data = json.load(f)
    return data.get('metrics', {})

def read_csv_metrics(csv_path: Path):
    with csv_path.open('r', encoding='utf-8') as f:
        rows = list(csv.reader(f))
    header = rows[0]
    metrics_row = None
    for r in rows:
        if len(r) > 0 and r[0].strip().upper() == '"METRICS"' or r[0].strip().upper() == 'METRICS':
            metrics_row = r
            break
    if metrics_row is None:
        return {}
    # Build map from header -> value
    vals = {}
    for i, key in enumerate(header):
        k = key.strip().strip('"')
        v = metrics_row[i].strip().strip('"') if i < len(metrics_row) else ''
        vals[k] = v
    return vals

def read_html_metrics(html_path: Path):
    text = html_path.read_text(encoding='utf-8')
    # Extract metric blocks: value and label
    blocks = re.findall(r'<div class="metric">\s*<div class="metric-value">(.*?)</div>\s*<div class="metric-label">(.*?)</div>', text, flags=re.S)
    html_metrics = {}
    for val, label in blocks:
        # Normalize label to canonical keys used in CSV/JSON
        lbl = label.strip().lower()
        if 'alpha_min_observed' in lbl:
            key = 'alpha_observed'
        elif 'perturb' in lbl and 'norm' in lbl:
            key = 'perturbation_norm'
        elif 'timing_jitter_ms' in lbl and 'p99' in lbl:
            key = 'timing_jitter_ms_p99'
        elif 'timing_jitter_ms' in lbl and 'p95' in lbl:
            key = 'timing_jitter_ms_p95'
        elif lbl.startswith('timing_jitter_ms'):
            key = 'timing_jitter_ms'
        else:
            # Ignore non-robustness cards like totals/pass rate
            continue
        html_metrics[key] = val.strip()
    return html_metrics

def to_float_or_null(s):
    if s in (None, '', '-', 'null'):
        return None
    try:
        return float(s)
    except Exception:
        return None

def compare(a, b, tol=1e-9):
    if a is None and b is None:
        return True
    if (a is None) != (b is None):
        return False
    return abs(a - b) <= tol

def main(json_path_str, csv_path_str, html_path_str):
    jp, cp, hp = Path(json_path_str), Path(csv_path_str), Path(html_path_str)
    jm = read_json_metrics(jp)
    cm = read_csv_metrics(cp)
    hm = read_html_metrics(hp)

    # Normalize aliases: treat timing_jitter_ms as P95 when explicit P95 missing
    for m in (jm, cm, hm):
        if m is None:
            continue
        # Fill P95 from default jitter when P95 missing or null
        if ('timing_jitter_ms_p95' not in m or to_float_or_null(m.get('timing_jitter_ms_p95')) is None) and 'timing_jitter_ms' in m:
            m['timing_jitter_ms_p95'] = m.get('timing_jitter_ms')
        # If P99 exists but not present in csv/json older formats, leave as None

    keys = {
        'alpha_observed': 'Alpha (observed)',
        'timing_jitter_ms_p95': 'Jitter P95',
        'timing_jitter_ms_p99': 'Jitter P99',
        'perturbation_norm': 'Perturbation Norm'
    }

    print('[CONSISTENCY CHECK]')
    all_ok = True
    for k, label in keys.items():
        jv = to_float_or_null(jm.get(k))
        cv = to_float_or_null(cm.get(k))
        hv = to_float_or_null(hm.get(k))
        ok_json_csv = compare(jv, cv)
        ok_json_html = compare(jv, hv)
        ok_csv_html = compare(cv, hv)
        ok = ok_json_csv and ok_json_html and ok_csv_html
        all_ok = all_ok and ok
        print(f' - {label} ({k}):')
        print(f'    JSON={jv} | CSV={cv} | HTML={hv} | OK={ok}')

    if all_ok:
        print('[RESULT] All metrics agree across JSON, CSV, and HTML.')
        return 0
    else:
        print('[RESULT] Disagreement detected. See above lines for differences.')
        return 1

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('Usage: consistency_check.py <results.json> <results.csv> <results.html>')
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2], sys.argv[3]))
