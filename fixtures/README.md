# Test fixtures

Files here are served over HTTP for the end-to-end tests in `PeteBJJCompFeedAPIEndToEndTests`; they are not bundled into any target.

- `e2e/event-image.png` is the image that `test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData` downloads. The test loads it from a commit-pinned `raw.githubusercontent.com` URL so it never changes under the test.
