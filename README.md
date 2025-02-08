# beyondsky

beyond sky is a bluesky client for android and linux made with Flutter and Material Design 3 

## Work in progress (Experimental Project)

I started this project as a way to learn Flutter so there are lot of bugs and unoptimized area.
Originally I had idea to make Bluesky look somewhat media focused with gallery style feed. For now it has following features:
- Single Timeline (Default one)
- Display Image(s)
- Minimal Profile Page

- Like/Unlike a post but it does not reflect visually even thought it recorded your like/unlike
- Uses Riverpod's `AsyncNotifier` for fetching feed and profile and auth purpose

- Does not show any other media other than images
- Every time you change page, it will refetch entire thing. Both for feed and profile
- Session Token once expires, have to relogin again
- No dark mode (for now)

- Will be adding toggle to show text posts with media posts
- and toggle to switch from gallery to timeline view as default in profile page.