# Challenge: root or administrator credential recovery

## Situation

While reusing lab VMs, the project required recovery of a forgotten account password and clarification of Ubuntu's root-account behavior.


## Key distinction

- **Forgotten normal user's password:** reset that named user's password from an authorized recovery shell.
- **Need to set a root password:** Ubuntu commonly keeps direct root login disabled/locked by default; use `sudo passwd root` only when an explicit root password is genuinely required.
- **Lost all administrative access:** use the hypervisor console and the OS-supported recovery procedure, subject to disk encryption and boot security controls.


## Ubuntu recovery outline

1. Open the VM console and reboot.
2. Enter GRUB (UEFI systems commonly use Esc; BIOS systems may use Shift).
3. Select the recovery entry and root shell.
4. Remount the root filesystem read/write if necessary:
   ```bash
   mount -o remount,rw /
   ```
5. Identify the correct account, then reset only that account:
   ```bash
   ls /home
   passwd <username>
   ```
6. If explicitly required, set the root password:
   ```bash
   passwd root
   ```
7. Reboot and validate normal login and `sudo`.

Exact menus vary by Ubuntu release and boot configuration. Use this only on a system you are authorized to administer.


## Security note

GRUB kernel editing (for example, changing boot parameters to start a shell) bypasses normal login controls when console/boot access is available. It is a recovery technique, not a routine administration method. Protect hypervisor access and boot configuration; full-disk encryption changes the recovery assumptions.


## Prevention

- Maintain at least one named admin account with tested `sudo`.
- Store credentials in an approved password manager.
- Test console access before hardening remote paths.
- Keep a known-good snapshot before risky changes.
