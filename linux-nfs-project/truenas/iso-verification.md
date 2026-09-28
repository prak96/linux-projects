# TrueNAS ISO Verification

## Purpose

The TrueNAS ISO was used as the storage platform installation media for the lab.

Before deploying the storage VM, ISO integrity should be validated using the checksum published with the corresponding TrueNAS release.

---

## Verification Workflow

```text
Download ISO
     ↓
Obtain official checksum
     ↓
Calculate local checksum
     ↓
Compare values
     ↓
Proceed with installation
```

Example Linux workflow:

```bash
sha256sum <truenas-iso-file>
```

Compare the output with the checksum published for the exact ISO release.

---

## Important

Do not document a checksum value unless it was actually verified for the ISO used in this project.

The repository should record:

* TrueNAS version
* ISO filename
* SHA256 checksum
* Verification result

This prevents the documentation from claiming an integrity check that was not actually performed.
