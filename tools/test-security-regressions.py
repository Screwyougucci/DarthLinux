#!/usr/bin/env python3
"""Source-level regression checks for security-sensitive Darth Linux defaults."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SecurityRegressionTests(unittest.TestCase):
    def test_libvirt_bridge_is_not_unconditionally_trusted(self):
        rules = (ROOT / "profiles/darth/airootfs/etc/nftables.conf").read_text()
        self.assertNotIn('iifname "virbr*" accept', rules)
        self.assertIn('iifname "virbr*" udp dport { 53, 67, 547 } accept', rules)
        self.assertIn('iifname "virbr*" tcp dport 53 accept', rules)

    def test_system_upgrade_has_no_kill_timeout(self):
        settings = (ROOT / "tools/darth-settings").read_text()
        self.assertIn('["pkexec", "/usr/bin/pacman", "-Syu", "--noconfirm"]', settings)
        self.assertNotIn("timeout=3600", settings)

    def test_store_package_transactions_have_no_kill_timeout(self):
        store = (ROOT / "tools/darth-store").read_text()
        self.assertNotIn("timeout=1800", store)
        self.assertNotIn("Package operation timed out after 30 minutes.", store)

    def test_rootkit_indicator_does_not_claim_a_scan_was_run(self):
        dashboard = (ROOT / "tools/darth-center").read_text()
        self.assertIn("Rootkit scanner binary (not scan status)", dashboard)


if __name__ == "__main__":
    unittest.main()
