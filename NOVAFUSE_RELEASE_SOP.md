# NovaFuse Release Standard Operating Procedure

## 🎯 Identity + Timing Rule

**Never add badges until repo identity and workflow identity have completed at least one full, successful cycle.**

### ✅ Correct Ordering

1. **Rename Repository** (if needed)
2. **Commit Workflow** (final name)
3. **Trigger Workflow** (run once successfully)
4. **Wait for Green** (completion confirmed)
5. **Create Release** (then add badges)

### 🚫 What Breaks Badges

- Adding badges before workflow completes
- Creating release before workflow runs
- Repository rename + workflow change in same cycle
- Any change to identity tuple (owner/repo/workflow)

---

## 🎯 NovaFuse Badge Block (Copy-Paste Ready)

Use this exact block for all NovaFuse releases:

```markdown
[![Verification](https://github.com/Dartan1983/NovaFuse-GMI-VS/actions/workflows/gmi-vs-verify-and-release.yml/badge.svg?branch=main)](https://github.com/Dartan1983/NovaFuse-GMI-VS/actions/workflows/gmi-vs-verify-and-release.yml) [![License](https://img.shields.io/github/license/Dartan1983/NovaFuse-GMI-VS?color=blue)](https://github.com/Dartan1983/NovaFuse-GMI-VS/blob/main/LICENSE) [![Release](https://img.shields.io/github/v/release/Dartan1983/NovaFuse-GMI-VS?color=purple)](https://github.com/Dartan1983/NovaFuse-GMI-VS/releases)
```

### 📋 Notes

- **Workflow File**: `gmi-vs-verify-and-release.yml` (final)
- **Main Branch**: `?branch=main` (prevents unknown states)
- **License Path**: Points to `LICENSE` file (not repo root)
- **Release Path**: Points to releases page

---

## 🔧 Implementation Checklist

### Pre-Release
- [ ] Repository name finalized
- [ ] Workflow file committed
- [ ] Workflow runs successfully once
- [ ] Badge block tested locally

### Release Process
- [ ] Create release with badge block
- [ ] Verify all badges render correctly
- [ ] Publish release

### Post-Release
- [ ] Confirm badge status in README
- [ ] Update any documentation

---

*This SOP prevents identity + timing badge issues permanently.*
