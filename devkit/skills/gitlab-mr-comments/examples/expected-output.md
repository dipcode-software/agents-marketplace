## MR Comments

- @jdoe (2024-03-10):
  > This MR looks good overall, but I have a few concerns about error handling in the auth module.

- @jdoe (2024-03-10) `src/auth/token.py#L42-L44`:
  > This function doesn't handle the case where `token` is expired. Should add a check before proceeding.

  - @asmith (2024-03-10):
    > Good catch, I'll add a token expiry check.

- @bwong (2024-03-11) `src/utils/logger.py#L18` [resolved]:
  > Consider using `logging.warning()` instead of `print()` here for production readiness.

- @clee (2024-03-11) `src/auth/validate.py#L15-L20 (old)`:
  > This validation logic was important — why was it removed?
