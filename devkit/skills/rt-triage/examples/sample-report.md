RT Triage Report — Queue: `client-portal`
Owner filter: all
Repository: `/home/user/repos/client-portal`
Date: 2026-03-24
Tickets analyzed: 8 | Actionable (code-related): 4

## Code Fix
- [#45231](https://rt.example.com/Ticket/Display.html?id=45231): Login page returns 500 after password reset — Stack trace points to `src/auth/views.py:authenticate_user()` where the reset token is not being invalidated after use; `src/auth/tokens.py` also involved.
- [#45218](https://rt.example.com/Ticket/Display.html?id=45218): CSV export missing "Total" column — The export logic in `src/reports/exporters.py:generate_csv()` does not include the computed `total` field from `src/reports/models.py:ReportEntry`.

## Code Investigation
- [#45240](https://rt.example.com/Ticket/Display.html?id=45240): Dashboard loads slowly for users with 500+ projects — Likely related to N+1 queries in `src/dashboard/views.py:DashboardView.get_queryset()`; needs profiling to confirm.
- [#45225](https://rt.example.com/Ticket/Display.html?id=45225): "Last login" date seems wrong for some users — May be a timezone conversion issue in `src/accounts/serializers.py`; requires inspection of how `last_login` is stored vs displayed.

## Not Code-Related
- [#45233](https://rt.example.com/Ticket/Display.html?id=45233): Cannot access VPN from new office — Network/infrastructure issue, not related to this codebase.
- [#45229](https://rt.example.com/Ticket/Display.html?id=45229): Please update the user guide PDF — Documentation request, no code involved.

## Unclear
- [#45242](https://rt.example.com/Ticket/Display.html?id=45242): "It doesn't work" — No details provided about what feature is affected or what error occurs. Needs client clarification.
- [#45237](https://rt.example.com/Ticket/Display.html?id=45237): Problem with the report — Could refer to multiple report types; no error message or screenshot provided.

---

### Owner-filtered variant

When invoked with `owner=john`, the report header changes to:

```
RT Triage Report — Queue: `client-portal`
Owner filter: john
Repository: `/home/user/repos/client-portal`
Date: 2026-03-24
Tickets analyzed: 3 | Actionable (code-related): 2
```
