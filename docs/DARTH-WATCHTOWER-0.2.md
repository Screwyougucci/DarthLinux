# Darth Watchtower 0.2 — Visual Editions & Analytics Plan

**Project:** Darth Linux  
**Target release:** 0.2 — The Security Awakening  
**Status:** Planning specification only — not implemented  
**Scope:** This document records the proposed Watchtower design and behavior. It does not claim that any feature is currently implemented.

## Goals

Darth Watchtower is planned as the central local system and security monitoring application for Darth Linux. It should combine useful system telemetry, security-event history, and customizable dashboards in one interface.

The visual theme must never change monitoring behavior, security policy, or the meaning of data. Every graph must be based on real collected measurements or clearly labeled sample/demo data.

## Visual editions

All five editions use the same monitoring engine and data model. Users can switch themes without losing dashboard layouts or history.

1. **Cyberpunk** — neon purple, cyan, and pink; animated network visuals and bright alert accents.
2. **Darth Red** — near-black and crimson Darth Linux identity; tactical panels and high-contrast security indicators.
3. **Matrix** — green-on-black terminal aesthetic; compact connection tables and process-focused panels.
4. **Ghost** — restrained dark glass styling with blue/white highlights and a clean, low-distraction layout.
5. **Command** — dense multi-panel operations layout for users who want many metrics visible at once.

Theme assets should be declarative and data-only where practical. Imported themes must be validated and must not be able to execute code with elevated privileges. A theme marketplace is a future distribution feature, not permission to run arbitrary theme scripts.

## Analytics and graph panels

The planned dashboard includes these eight panels:

| Panel | Planned information |
| --- | --- |
| Network traffic | Upload/download throughput and historical traffic |
| CPU/RAM | Processor and memory utilization over time |
| Firewall activity | Allowed and blocked events, with timestamps and rule context |
| Threat timeline | Chronological security events from supported sources |
| Connection map | Locally observed active connections and their endpoints |
| Disk performance | Read/write throughput, capacity, and relevant disk activity |
| Login attempts | Successful and failed authentication events available from local logs |
| Antivirus detections | Scan results, detections, quarantine and restore events |

### Data integrity

- Graphs must display real local measurements, not fabricated activity.
- Demo values must be clearly labeled as sample data.
- Show units, time ranges, collection timestamps, and data-source status.
- Missing or unavailable sources must be shown as unavailable, not as zero.
- Connection maps show only information the local system can legitimately observe; they must not imply visibility into remote networks.
- Event counts should avoid double-counting duplicate records where source identifiers allow deduplication.

## Customization features

1. **Custom dashboard layouts** — add, remove, resize, and rearrange supported widgets.
2. **Animated graphs** — optional motion for live updates; provide a reduced-motion option.
3. **Theme marketplace** — browse and install reviewed theme packages; verify package integrity and provenance.
4. **Full-screen monitoring** — distraction-free display mode for a dedicated screen.
5. **Multiple saved dashboards** — named layouts for system health, network activity, and security review.
6. **PDF/CSV exports** — export selected time ranges with timestamps, units, and data-source details.

## Local-first architecture

- Monitoring and dashboard rendering should work offline.
- Store history locally and provide configurable retention limits.
- Use bounded storage and sampling so long-running monitoring does not fill disks or overwhelm low-resource machines.
- Separate unprivileged UI code from any privileged data collectors.
- Collect only the minimum data required for each panel.
- Do not add hidden telemetry or upload monitoring history.
- Make collection status and retention settings visible to the user.

## Performance and accessibility

Darth Linux targets older laptops and low-resource computers. Watchtower should therefore:

- Start with a lightweight default dashboard.
- Allow expensive panels and high-frequency sampling to be disabled.
- Use bounded history and configurable refresh rates.
- Avoid requiring a dedicated GPU.
- Offer reduced motion, readable contrast, keyboard navigation, and scalable layouts.
- Keep full-screen mode optional.

## Integration with the Darth Linux 0.2 suite

- **Command Center:** displays Watchtower health and opens its dashboards.
- **Sentinel Antivirus:** provides scan, detection, quarantine, and restore events.
- **Guardian Firewall:** provides firewall status and allowed/blocked event data.
- **Darth Privacy:** exposes relevant privacy status without collecting unnecessary personal data.
- **Darth Lockdown:** records policy changes and lockdown state transitions.
- **Darth Recovery:** records recovery operations and can help users diagnose failed changes.
- **Darth Store:** distributes signed Watchtower releases and reviewed themes.
- **Darth AI:** may explain selected events locally, but must not silently change system settings.
- **Darth Red Lab:** may expose authorized lab activity as a separate, clearly labeled dashboard source.

## Security and privacy requirements

- No theme may weaken or bypass monitoring, firewall, antivirus, or operating-system controls.
- Export actions must be explicit and show what data will be included.
- Exports may contain sensitive hostnames, addresses, usernames, and security events; warn users before sharing them.
- Protect local history with appropriate file permissions.
- Do not claim that a graph proves a system is safe or that all threats have been detected.
- Show the source and limitations of each security signal.

## Proposed acceptance tests

- [ ] All five themes can be selected without changing monitoring behavior.
- [ ] Theme switching preserves saved dashboard layouts.
- [ ] Each graph displays real measurements or an explicit demo label.
- [ ] Missing data sources are represented as unavailable.
- [ ] Network, CPU/RAM, disk, firewall, login, and antivirus panels are tested against known local test events.
- [ ] Threat timeline records timestamps and source information.
- [ ] Connection map displays only locally observable connection metadata.
- [ ] Custom layouts can be saved, reopened, and reset.
- [ ] Animations can be disabled.
- [ ] Full-screen mode can be exited with keyboard controls.
- [ ] Multiple dashboards can be saved independently.
- [ ] PDF and CSV exports preserve units, timestamps, and source context.
- [ ] Theme packages are validated and cannot execute privileged code.
- [ ] History retention and storage limits work on low-resource hardware.
- [ ] Offline operation is verified and no hidden telemetry is introduced.

## Delivery status

This is a planning document for Darth Linux 0.2. No Watchtower application implementation, theme marketplace, monitoring service, or graph collector is delivered by this specification.
