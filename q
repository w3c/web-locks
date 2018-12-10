[33mcommit b2e4a2d084215d2a8b8cd530216e2ea2b651db6c[m[33m ([m[1;36mHEAD -> [m[1;32mquery-order-change[m[33m)[m
Author: Andreas Butler <andreasbutler@google.com>
Date:   Mon Dec 10 14:42:00 2018 -0800

    [WebLocks]: Specifying ordering for navigator.locks.query()

[33mcommit b3af6bf3658c91f89c18c239ae2d8d5607025a02[m
Author: Andreas Butler <andreasbutler@google.com>
Date:   Mon Dec 10 14:42:00 2018 -0800

    [WebLocks]: Specifying ordering for navigator.locks.query()

[33mcommit 2b6dcdbe9a16e0daedbd6f84931e56e7c476894a[m[33m ([m[1;31morigin/master[m[33m, [m[1;31morigin/HEAD[m[33m, [m[1;32mmaster[m[33m)[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Oct 23 13:15:37 2018 -0700

    Editorial: Link to TAG private-mode doc (WIP), rather than wikipedia

[33mcommit 872339199e24736ef327b240e605d5e13d3d7043[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Oct 22 12:16:02 2018 -0700

    Linkify 'invoking', which will promisify result as needed. Fixes #53

[33mcommit 883025d5121f31746373c44203f7183a4ffe2bc3[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Oct 22 12:10:33 2018 -0700

    LockGrantedCallback arg should be nullable. Fixes #51

[33mcommit 00ce6f48c97ab8b6e646907350ee21c9282f29d6[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Sep 7 12:43:44 2018 -0700

    Editorial: Ack devsnek

[33mcommit 5dfb614a0e0f43f00e627420ee1667168321af90[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 7 12:42:23 2018 -0700

    Invoke callbacks on explicit event loop. Resolves #47 (#48)
    
    Steps running on a separate task queue can't just invoke callbacks. Change the steps to explicitly enqueue invocation on the appropriate event task queue.

[33mcommit e313a04516e3fdf93505e9c65653f7a11bbac128[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 24 14:31:27 2018 -0700

    Editorial: delimit examples with backtick code blocks rather than tags

[33mcommit 17def71742c841886229b1679667c8963d1e9305[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 24 14:24:38 2018 -0700

    Editorial: use xmp instead of pre

[33mcommit 3b492196c99ef8f8227a6079df643a74f2ce8ed5[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Aug 20 14:52:47 2018 -0700

    IDL: Fix exposure of LockManager for workers

[33mcommit 44bfb641cbab817bac557f78fcec24fdaa2bbf60[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Aug 20 12:01:15 2018 -0700

    Editorial: Update Security/Privacy section to make first/third-party behavior explicit

[33mcommit 4e4c9eb74816959d1665cb9433ed04b1981cd73d[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Aug 20 11:57:54 2018 -0700

    Updated security/privacy doc re: third-party behavior

[33mcommit 197186cbe5da9bf5c97f2e6212421daced16049d[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 11:10:40 2018 -0700

    Split landing page and explainer

[33mcommit 9ce9353792c0842715e7f3f467a6ba289c81dd54[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 11:06:52 2018 -0700

    Explainer: Add link to MDN docs

[33mcommit b7bc471f75c51b6f2e43788a1cf97c1e35a3430e[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 09:28:08 2018 -0700

    Remove obsolete polyfills

[33mcommit 5cc1bd560fc4bcf9822c8d0dd58d1c16d86c96f6[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 09:25:49 2018 -0700

    Add build status indicator

[33mcommit 5aeb88c7c4cff47e3b72d42b70f2835b9982994a[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 09:18:26 2018 -0700

    Mark compile.sh as executable

[33mcommit 622c4d1fdc055435320f7cd7fdbdc7ca8d941ff6[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 09:15:23 2018 -0700

    Change to test auto-build/deploy

[33mcommit a43230071c4303864d3054830d5c40c7f5a719a1[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 09:14:26 2018 -0700

    remove unneeded file in master

[33mcommit 2781260465d8a759452fb6eea0d5cd2fa9403bb3[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 17 09:09:36 2018 -0700

    Master branch changes for auto-deploy

[33mcommit 19166586c2fad9bb5a671e375a697cbf3b14031c[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Aug 14 07:51:25 2018 -0700

    TOC tweaks

[33mcommit 0e7871689305cbb3c2d3fdd93d374ed9d74cfb06[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 10 10:34:20 2018 -0700

    Update intra-repo links

[33mcommit dfac2ae13b356984424a2a2907b7915e0764790c[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Aug 10 10:27:12 2018 -0700

    Update tests link

[33mcommit cd708e1680b193cc2112ca504d8eb96f67098b6d[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Jul 24 10:47:18 2018 -0700

    Typo

[33mcommit ed84f177f7f41ec2bee0914c30944092bc57851f[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Jul 10 17:23:41 2018 -0700

    Editorial: Update Test Suite link

[33mcommit 877c3af9d945db0c96c3465dfb8e350fe2c1656b[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Jul 10 17:13:08 2018 -0700

    Editorial: Use Bikeshed 'Favicon' option

[33mcommit 1e6d65ee0b9a79b685544164520d3ca9679396ba[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Jul 10 17:08:17 2018 -0700

    Editorial: Add IDs for all examples

[33mcommit 5728f8cf9d35c7bcc9c9acace26ec2020bfc3d2a[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Jul 10 17:05:07 2018 -0700

    Define lock manager scope relative to site storage unit. Resolves #45.
    
    Changed in non-normative areas. Should be made normative here and/or
    in Storage and linked.
    
    Also: fix a reference to 'lock request/agent'

[33mcommit 91ce92f37bf956a71ecec160d5a2ec4d286138d0[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Jun 11 16:38:16 2018 -0700

    Add Security section (and de-smart-quote)

[33mcommit f7fd1a6e6911cf56beb7e82b60bb26bb0e8e1060[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Thu May 31 10:45:57 2018 -0700

    Make logo link relative

[33mcommit dd635b206713b2b965bf0d853fc866622b365605[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue May 8 15:04:05 2018 -0700

    Bikeshed update

[33mcommit 387d7d7f63bf295dd98e998e5792ce473971f750[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Apr 24 16:48:19 2018 -0700

    wordsmithing, linkify modes, move user agent defn

[33mcommit 101f090a6346101f6dc0b50dd4bd4f36db9409c6[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 15:20:06 2018 -0700

    Migrate use cases, deadlocks from README

[33mcommit cd7bb2c2452162c1957ba9d827a7181c4945201d[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 14:35:44 2018 -0700

    Markdown shortcuts

[33mcommit cdd7c030924660479ce19a6207580db9fcc97e45[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 14:28:48 2018 -0700

    Advisements

[33mcommit ebd7e4859f634f94f96ffc71f948401d0e0492e6[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 11:17:40 2018 -0700

    Correct indentation of steps

[33mcommit bc3ac54ee9fb425997bb65d857d21da4dfef7c88[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 11:14:26 2018 -0700

    Blurb for LockManager; if/then consistency

[33mcommit e1d32551b5159f84df811b1939393f21eb57203c[m
Merge: e503c96 a77b8fd
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 10:20:40 2018 -0700

    Merge branch 'master' of https://github.com/inexorabletash/web-locks

[33mcommit e503c9688b38e8cfb78671a13c224bc81ab928c1[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Apr 20 10:20:37 2018 -0700

    Remove obsolete forceRelease method. Fixes #43

[33mcommit a77b8fdd38e690312bcdc195b71154dabd8fc887[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Apr 19 09:40:16 2018 -0700

    Replace proto-spec link

[33mcommit f45c74dd38d4fcb6a0b09ad35ffa20e928f94c1e[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Apr 19 09:37:00 2018 -0700

    Tidy

[33mcommit 4b54a68be745e8bdf86dd35e44b5abbbc247d275[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Apr 19 09:35:14 2018 -0700

    Replace proto-spec with link to real deal

[33mcommit 85df57ad67e8013ac3b89ce2a25906dbe025b5db[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Wed Apr 18 18:09:53 2018 -0700

    Add preliminary spec bs

[33mcommit 3292ec7f20b014c2a9d5bb2aea73d81224d27573[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Mar 14 11:17:19 2018 -0700

    Add section on Lock Manager Scope
    
    As discussed in https://github.com/mozilla/standards-positions/issues/64 the scope of locks needs to be well defined.

[33mcommit f048a44116d8e62bbcbbd93760ed046d7ad1caec[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Mar 13 18:12:51 2018 -0700

    Update acks

[33mcommit 72090f62427603ddaae8b28653e465ada34aa79d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Mar 2 12:13:08 2018 -0800

    Rework abstract/intro
    
    Thanks to @marcoscaeres for the valuable feedack!

[33mcommit 6a6af7292a07703a1c831a455befdbdb524e3728[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Mar 1 11:23:09 2018 -0800

    Add example using return value from callback.

[33mcommit 9108c8fc03501c287226f7c0f749dc3e7f8a042f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Feb 16 11:02:58 2018 -0800

    Remove 'optional' from overload

[33mcommit 52baa23ed1df62fdddc97b0b7ffc6ecd6697fc02[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Feb 12 15:41:34 2018 -0800

    Ack Luciano Pacheco

[33mcommit 6a1f20a4c86f07e96efe3106eb5c844349fdd4b2[m
Author: lucmult <lucmult@gmail.com>
Date:   Tue Feb 13 10:40:40 2018 +1100

    simple format typo (#37)
    
    Missing punctuation.

[33mcommit 562048c0737e7307c4c6493ed4bee3add316d99c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Feb 9 13:34:24 2018 -0800

    Clarify example for failed request, link to issue #13

[33mcommit c4fee9359a2fd2722197c1ef4a7d5af6e61af964[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Feb 8 09:19:16 2018 -0800

    Update entry point from acquire() to request()
    
    Per discussion in https://github.com/inexorabletash/web-locks/issues/35

[33mcommit 22d0e69e14e1b6233413f587e354d3a01002b860[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Feb 8 09:18:05 2018 -0800

    Rename entry point from acquire() to request()
    
    Per discussion in https://github.com/inexorabletash/web-locks/issues/35

[33mcommit 1cf2d6ba5f4ced5ef3d6da8a383b05177f202b85[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Feb 7 16:58:31 2018 -0800

    Add links to more lock APIs in the platform

[33mcommit 458d9313fac195134a703ae21fe245105fd93766[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Feb 7 16:06:26 2018 -0800

    Disallow leading '-' in names. Resolves #29

[33mcommit a21e558bcae22550426b26e02efd1b63ef4b5215[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Feb 7 15:59:51 2018 -0800

    Reserve names with '-' for the future.
    
    For issue #29

[33mcommit a6ecae619c348b0d886d70b422404f9fe703739d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Feb 7 12:18:24 2018 -0800

    Reworked request/signal algorithm hookup. Resolves #34

[33mcommit 340cfdba286199c2d767084412c348f3855aef13[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Feb 7 11:36:56 2018 -0800

    No-op signalling a granted request. Resolves #27

[33mcommit ecaaaf80814b9a38691cd37ee12abff03f1d5ba9[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Feb 2 11:50:01 2018 -0800

    Ban shared + steal
    
    Pending figuring out what this should do, just disallow

[33mcommit 0c08cb1198900821d36f8859e5a8815f54fb0051[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Feb 1 17:16:30 2018 -0800

    Update explainer behavior of steal

[33mcommit 16e62a11f6cb294a927427b486535650857abbb0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 31 11:41:30 2018 -0800

    Make signal + (steal || ifAvailable) disallowed
    
    https://github.com/inexorabletash/web-locks/issues/23#issuecomment-362045149

[33mcommit 3c8b9bbb718ce0609a70e23e4511d8f46f8b1c7a[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Jan 30 13:28:20 2018 -0800

    Add note about nested requests, for issue #33

[33mcommit 9d31f68bd89dfe3f6f962f2636b2ca88699e40af[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Jan 30 12:33:05 2018 -0800

    Throw if both steal and ifAvailable are specified

[33mcommit 56b04ffc1e6b050cc4850ec8d6bd55f3c9bf3caa[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 29 13:33:17 2018 -0800

    if/then consistency

[33mcommit 3c4115983dcad78d973e83a690ebde3da1d6945f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 29 13:31:26 2018 -0800

    Steal does not drop requests, just takes priority over them

[33mcommit 9fd7d0050c4a8651234b48863615cdf060c9d2f0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 26 15:28:37 2018 -0800

    Swap release/held cleanup order in steal
    
    When processing the steal option, drop pending lock requests before dropping held locks. This ensures that a dropped lock does not cause a lock to be granted. Since the lock queue is not processed during this iteration it should be irrelevant, but... paranoia.

[33mcommit 60e9141c0740cc76b1241b18d8fb02d95711d873[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 22 15:58:31 2018 -0800

    Typo

[33mcommit 4e54a71020e0ccbebb38c6380cba2af3218bd504[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Jan 11 12:55:45 2018 -0800

    Add "never released locks" use case/example

[33mcommit 35ec572ce69f99e19f6ac39d3f48490b5fcf2e3e[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 16:12:21 2018 -0800

    steal should default to false

[33mcommit 314e74edf818760f2ccb454fe505faaae43ca862[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 16:11:45 2018 -0800

    Incorporating feedback on deadlock part of explainer

[33mcommit fc97950095728fb4c434589b101e2b1e03a7aad1[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 13:13:18 2018 -0800

    Drop "origin flags" which no-one but me likely remembers.

[33mcommit 3053572be0a6ebc431dfb95286345b7dbccd801e[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 12:54:43 2018 -0800

    add "frames" to informal list of agent types

[33mcommit 9ecba53f134e066faa2249dae1de236c7f81cf9f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 12:54:03 2018 -0800

    Added section on deadlocks

[33mcommit e58a2bd6048a9ee3a1bc2058245e686cb3ae5fc7[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 12:28:42 2018 -0800

    Added section about steal option

[33mcommit e252badb3146fc9ec0da4e58ae3f65dd420c881d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Jan 10 12:20:48 2018 -0800

    Add Acknowledgements

[33mcommit c68b396020d38337d20007a7ceb82ac1dc07d233[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Jan 9 10:58:23 2018 -0800

    Added query() description to explainer

[33mcommit 602fda46048257e605f709ff4d973b7b61dc493c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 15:35:56 2018 -0800

    Add clientId property to snapshot state
    
    For https://github.com/inexorabletash/web-locks/issues/26

[33mcommit 978193ef35a320b55eb2db193ef5ba7de082b0dc[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 12:31:28 2018 -0800

    Correct possessive of options

[33mcommit 74c2ec09705e66f7b9a27f45d48328e2d4ec196c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 12:29:26 2018 -0800

    AbortSignal: Handle pre-aborted signal
    
    For https://github.com/inexorabletash/web-locks/issues/27

[33mcommit 9f07b6f5890840d7b0b02152436cf21e1b6e229f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 12:19:34 2018 -0800

    Have AbortSignal use the "abort the request" steps.

[33mcommit 66db575ef45b9d3029d5d1d97678530f600b9d62[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 11:04:29 2018 -0800

    Add TOC

[33mcommit 48d3131be3a55a73c0a7cd2aa91161df68b40664[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:55:16 2018 -0800

    Remove warning, add logo

[33mcommit f358818e8d4329e433c1c1cc85f796589cfaeaa7[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:54:28 2018 -0800

    Linkify assert (to Infra)

[33mcommit 375726b3df7322a2922f86df7a398013e8cc9b68[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:53:23 2018 -0800

    Make algorithms assert where they are run

[33mcommit 18356dacaff039616e485b1fe589c2cedb34505a[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:51:04 2018 -0800

    Factor "snapshot the lock state" into separate algorithm

[33mcommit 382956b9a58189fe3eeceab57100dc37cc1cf3fb[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:43:09 2018 -0800

    Fix IDL for LockManagerSnapshot dictionary
    
    type then name, duh

[33mcommit 1c94abf38a6e08fdc7572d93fa289b1b3095bcfe[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:41:00 2018 -0800

    Use actual mixin syntax in WebIDL

[33mcommit 6afb5df723871e0d3f9c487f8e992c1958c8f0c3[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Jan 8 10:36:24 2018 -0800

    Expand normative note about lock's promises

[33mcommit 042f7d375654e3ca77d7d8c5780618093bbf129e[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 16:51:18 2018 -0800

    type safety in spec algorithms, yo

[33mcommit 74b9eae27a0b5e9c897c6c02a414b59ddf8891a0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 16:46:20 2018 -0800

    Add some more non-normative notes.

[33mcommit 84a4121b7c2399aeb0b1ea646eeb552b2badec9d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 16:25:25 2018 -0800

    name is DOMString - singular

[33mcommit 27e7fd3f5381c8c493cf5b9ecd9f4afbd55232f3[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 16:25:04 2018 -0800

    Fix formatting of LockOptions type

[33mcommit d033e805412d13951ad0d9ddf840bd2eec0eafda[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 16:20:33 2018 -0800

    Update README.md

[33mcommit cc7f4f613f3dd99bd160ddbf5acee300312abc23[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 16:19:58 2018 -0800

    Update README.md

[33mcommit 40ae0e80a01b3b46f39cdd9d673795ac04d7cbed[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 14:27:51 2018 -0800

    Add non-normative section distinguishing the associated promises

[33mcommit 8be06821c16b4f098d32da89cbcdf248197e63c3[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 14:22:33 2018 -0800

    Normalize promise creation in steps

[33mcommit 8f896c8c613e52bd62da2a31d11ae24989563c2c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Jan 5 14:12:46 2018 -0800

    First stab at integrating with agent termination

[33mcommit 8064fb9fc885be64ee7644b38f752d4bae0626bf[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 17:20:01 2017 -0800

    Define steal option and behavior. For #23

[33mcommit 408734b452d441a9cf7373d82196ee4e8e481ed2[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 16:39:40 2017 -0800

    Expose "process the lock request queue"
    
    This allows the parallel wait construct to be removed.

[33mcommit 134481469fc9f980400af5c88901b5d962f05460[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 16:23:45 2017 -0800

    Hook up AbortSignal properly

[33mcommit 4342f0cd45d0fca13cf26e69af698cef9af70eff[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 16:14:16 2017 -0800

    Remove dangling return from parallel steps.

[33mcommit b4b172997ec35270f7e65706f4777eb1480ecdfc[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 16:11:04 2017 -0800

    Start specing in terms of parallel queues. For #22

[33mcommit 7e253f3baf820a619d461252f41b5c6f90a061bc[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 15:40:51 2017 -0800

    Rename query dictionaries

[33mcommit 46c4285b20eb1be7423467e4d1945c7111ea2c16[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 15:15:26 2017 -0800

    Name update

[33mcommit 054f59dd40d2acc59404f61532fac9cd48afba3f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Dec 20 15:08:28 2017 -0800

    queryState -> query, per #10

[33mcommit 144f08eeb417498b13a905854746c4f17af03d8c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Dec 18 17:14:40 2017 -0800

    Delete interface.webidl

[33mcommit 12c4dfbb9007e0a2c6b1e061e0274c45bbf005c9[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Dec 18 17:14:25 2017 -0800

    Update proto-spec.md

[33mcommit 9aa3605785ba457aad9de5c9f8ea50d5d1ff144c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Dec 18 17:13:34 2017 -0800

    Pull WebIDL into spec

[33mcommit 6348d20517b233065292d33ce7001cdb49f7c030[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Dec 18 17:05:33 2017 -0800

    Style dict types

[33mcommit 1c8e9058b07cb5ed728561957086885f84bc99bd[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Thu Dec 14 16:39:11 2017 -0800

    Drop multi-resource scopes. Resolves #20

[33mcommit 9ecc36488690735732494e938f52319dd6af3ee0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Dec 4 16:03:28 2017 -0800

    Better origin definition

[33mcommit 153b705b5405e551394e84a7920cf474a5cf186b[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Dec 4 15:58:29 2017 -0800

    Use automatic numbering (1. foo, 1. bar, ...)

[33mcommit 52b13c87ad1326be2d8ef367f4e46aa889fe8e3b[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Nov 29 12:33:01 2017 -0800

    Add WorkerNavigator, move SecureContext onto the partial

[33mcommit 6b52049e24e68c0118dca5d024103b58f1fe79cd[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Nov 29 12:26:38 2017 -0800

    Link to IDL from proto-spec

[33mcommit 79c814bc355478b9d7f5d7edd41c0e4657415cfb[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Nov 17 12:55:20 2017 -0800

    Switch options and callback order. Resolves #19

[33mcommit 04dd9bf29720c13b43f2d65ddff54464336fe3b6[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Nov 10 14:10:34 2017 -0800

    Create security-privacy-self-assessment.md

[33mcommit 439376e2bb41008b21dff38c914c4b0ca6e51094[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Nov 8 13:35:48 2017 -0800

    Update interface.webidl

[33mcommit f09ca597b422875858d80ad13323426a550a9a94[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Nov 7 14:33:37 2017 -0800

    First attempt at defining forceRelease

[33mcommit f48ec21eb0418c0284dffcf8b38d9d09aec51f0d[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Tue Nov 7 14:08:37 2017 -0800

    proto-spec: flesh out queryState algorithm

[33mcommit 5b17a007b75a3360c87800c2c5e1a86440d1842b[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Nov 7 10:43:04 2017 -0800

    Use 'IndexedDB' consistently

[33mcommit d27f64880964acb9812ad2a4aad7142c935d394d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Nov 7 10:33:15 2017 -0800

    Wordsmithing

[33mcommit b116905cc7d207f1433eff1172e53444b70f78ea[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Nov 6 15:46:05 2017 -0800

    Start incorporating revised API from #10

[33mcommit 7a5377d07130b88b53d26e4311309871a54dd708[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Nov 6 14:45:25 2017 -0800

    Convert "held" from a per-lock state to a per-origin set

[33mcommit 0d50c51567af7b6ff8b01966f0027af3e9dc9f57[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Nov 6 14:37:46 2017 -0800

    Styling enum members

[33mcommit 65a2bd4ac7b36e544831f846b29ce4dce66f0a79[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Nov 6 14:36:38 2017 -0800

    Use Infra type/ops for queue/list

[33mcommit e844787a32dcaa0d76c1cf1bdcdb2ec0e4e7bbba[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Nov 6 14:30:48 2017 -0800

    Fix typo

[33mcommit 7dfe84962531fa08336aa5b204f9a1c44e028c6f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Nov 6 14:30:07 2017 -0800

    Formatting of enum values

[33mcommit a110a9a1d76bdc39a8e1c8e8eb75725567644294[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Nov 3 15:29:28 2017 -0700

    Simplify lock logo path

[33mcommit b4bbc9ee056c844f4055446bc5723f2663d7caa0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Nov 3 15:02:50 2017 -0700

    Update FAQ items about composing IDB transactions with locks

[33mcommit aacf39a8c5416868aac228801baaa4773706a66a[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Nov 3 14:51:54 2017 -0700

    Settle on scoped-release API model, move other proposals to secondary document. Resolves #9

[33mcommit 286a1ec10a250e0b179cfada8a16d163bcc4ab3d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Nov 3 14:39:41 2017 -0700

    Try rawgit instead

[33mcommit e1a49c3c2b31aaab6e0afa7124bc6bec294b1ab9[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Nov 3 14:38:51 2017 -0700

    Use local copy of logo in README

[33mcommit 72a74131ab6fc5dc1a4323ff33f0e93b94293ace[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Nov 3 14:37:57 2017 -0700

    Add logo

[33mcommit 1cba19395e48abe3cddf3084cc7dbb86ff75d72e[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Fri Nov 3 09:35:52 2017 -0700

    Tossed [SecureContext] into IDLs. Resolves #11

[33mcommit efee3f552bd0222812ad140c6b73e97e6e329cbb[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Oct 6 14:34:45 2017 -0700

    typo in readme

[33mcommit 44b00a431ac72e5427a973a954b26fa079795a44[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Oct 5 10:58:59 2017 -0700

    Add FAQ note about Incognito mode (Resolves #15)

[33mcommit b98d3b5433ac73b3a0620f20de0b2273da871e39[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Oct 4 20:53:16 2017 -0700

    Fix typo (resolves #16)

[33mcommit 74d3298c02ab5b427a6679eab1783ce229fc2334[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Oct 4 10:43:44 2017 -0700

    Update proto-spec.md

[33mcommit adcfd32420d66a4bacf1167095a912d667f2eff0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Oct 3 17:41:38 2017 -0700

    Add ifAvailable option; rework to scoped-release style

[33mcommit a11448cb8a41e21013f4aecdf234156049b6790a[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Oct 3 17:22:38 2017 -0700

    Add ifAvailable option

[33mcommit 4a41d46a39221937c66329d7226a0ea3fae791e3[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Oct 3 17:19:40 2017 -0700

    Add ifAvailable option

[33mcommit 6814dd9bcbceab484ce6cc113ab5c40833e7e224[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:51:26 2017 -0700

    Update README.md

[33mcommit 073e7f3b633b5207e32267ae72e6120e853e126c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:50:25 2017 -0700

    Update README.md

[33mcommit 3654f152b3b1a79563906afef02f25731cb5db0a[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:49:28 2017 -0700

    Update README.md

[33mcommit 760ad661362ca205d668dd73a978f47869991ea3[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:49:05 2017 -0700

    Update README.md

[33mcommit 00c0d7a17667a43bddafe5c54054b76cdc9a2f6b[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:47:32 2017 -0700

    Add example of processing requests

[33mcommit 405e93679f82983f49bcd9c2dd6131ab8e38b92d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:31:16 2017 -0700

    Update timeout example

[33mcommit ccde1c2859566d04e8836aef286f059e44050805[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:27:05 2017 -0700

    Update README.md

[33mcommit 9b3eb69183d326faaf76737618678487cec7fd9c[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Oct 2 14:06:16 2017 -0700

    Update README.md

[33mcommit 07387221c2153f7c5cfea69e68ad0d3d810b1f78[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Wed Sep 27 15:26:39 2017 -0700

    Fix examples with mode

[33mcommit 9311a4fa8723ced03de3357432c9e6134f2bbff3[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Wed Sep 27 15:24:01 2017 -0700

    Move 'mode' to options. Resolves #3

[33mcommit bc9656865302b7a76c555fdf912b264430f7d3d8[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 25 16:20:43 2017 -0700

    Update README.md

[33mcommit bd9eee1a79eb024cc67cec9cbe4217a1f1c1979c[m
Author: Joshua Bell <jsbell@chromium.org>
Date:   Mon Sep 25 15:29:00 2017 -0700

    flag -> lock in polyfill

[33mcommit 37be9ebdd500dc719909c62cfeb09a8a8b922968[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 25 15:27:36 2017 -0700

    flag -> lock in IDL sketch

[33mcommit 5461481066530057fd50ecbeecb5acf73aa523da[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 25 15:24:19 2017 -0700

    flag -> lock in speclet

[33mcommit be62e664d45427e3cecb853551c756fdabd1472f[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 25 15:21:49 2017 -0700

    flag -> lock in readme

[33mcommit 73cac1e7a546fbbc586e51a191789c5e880f94b2[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 22 17:10:03 2017 -0700

    Update README.md

[33mcommit b996fb73820876d83f317dfc763a4bd720adac26[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Thu Sep 21 15:01:01 2017 -0700

    Update README.md

[33mcommit 07f43d0df24daa65b518f282dc34c74bd3f26519[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Sep 20 14:37:09 2017 -0700

    Add "scoped release" proposal

[33mcommit 943bc29c9e3f2b731885cf52319915911e29ad8a[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Wed Sep 20 14:26:02 2017 -0700

    Add "scoped release" proposal

[33mcommit 96dd7794a9474e42570fb9bfb29240a881f4eab9[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 12:18:20 2017 -0700

    Remove timeout

[33mcommit 1e86ead94ef73e0ffd21137347307d655b2a7d45[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 12:15:27 2017 -0700

    Remove timeout

[33mcommit 7cc351127c575d7bf161e1e09f06cbce7beafa50[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 12:12:34 2017 -0700

    options should be optional

[33mcommit b5e1e29cc1e6a4bf4529aa437ef790e8e8db3daf[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 12:10:40 2017 -0700

    Update proto-spec.md

[33mcommit ad086cf435f387b93951dc14b5516760e7829af9[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 11:51:47 2017 -0700

    Fix indenting of substeps

[33mcommit da92fc85736d80d4c4565759e09b405864675814[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 11:51:20 2017 -0700

    Use signal instead of timeout

[33mcommit be1916f74113d940f7b2ac6c3059010cd2499f26[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 11:38:22 2017 -0700

    Replace timeout with AbortSignal

[33mcommit 97c986c91b2950677d3990d15ec64546559f2035[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Tue Sep 19 11:36:59 2017 -0700

    Replace timeout option with signal option

[33mcommit c44c0e4fd0e1dea8ccf912d3f48c716d76de9cd7[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 18 09:59:32 2017 -0700

    Update README.md

[33mcommit 7b8b58f020fe98c80dd14a8fcbe82130ec419d48[m
Merge: 80fb7bc ad2aa56
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 18 09:49:28 2017 -0700

    Merge pull request #6 from jakearchibald/patch-1
    
    Missing 'at'

[33mcommit 80fb7bc6862193a372118c7cd916659eadc0bc1c[m
Merge: 601a2c3 e4c3112
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Mon Sep 18 09:49:11 2017 -0700

    Merge pull request #7 from jakearchibald/patch-2
    
    Minor syntax errors

[33mcommit e4c31128a2b58787f435755f3e3ad550c439cc98[m
Author: Jake Archibald <jaffathecake@gmail.com>
Date:   Mon Sep 18 13:40:27 2017 +0100

    Minor syntax errors

[33mcommit ad2aa56d0f3d14c4004a08e74a398f3b3d292edc[m
Author: Jake Archibald <jaffathecake@gmail.com>
Date:   Mon Sep 18 13:32:11 2017 +0100

    Missing 'at'

[33mcommit 601a2c3baf33adda2c1c580b7a4d06583661ecad[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 17:31:10 2017 -0700

    Update README.md

[33mcommit fb7ecb747803252fb267e7e4c80204a104457be4[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 16:41:33 2017 -0700

    Update README.md

[33mcommit 62605c87fe96775a9528e86ef37094f81bc4adbc[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 14:22:01 2017 -0700

    Update README.md

[33mcommit 81dee55b46697eefd123f0a5855a5143b58810a0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 14:14:55 2017 -0700

    Update README.md

[33mcommit a379590003b82834a431e4f76c1c312ab7019d8d[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 14:08:17 2017 -0700

    Update README.md

[33mcommit 86ea7518710a7695943f275afa89a37e0aec9c25[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 14:07:36 2017 -0700

    Update README.md

[33mcommit 103fc7f54fb85a143d49da4758aad12b0f419e18[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:28:32 2017 -0700

    Create polyfill-worker.js

[33mcommit 59c76b9496e5d1120523031ea30a74db1b83f363[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:27:47 2017 -0700

    Create polyfill.js

[33mcommit f514e849871d0b44646a681c227ef25182df8775[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:25:44 2017 -0700

    Create proto-spec.md

[33mcommit 195e08a9e829dd2b84c0ae657df960bddff39ce0[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:18:42 2017 -0700

    Create interface.webidl

[33mcommit bfb94c15e0fa371f20c80e632eecb6a8e51de3b7[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:15:27 2017 -0700

    Update README.md

[33mcommit baac502c5e6acb54a7373bc29493116f9998a658[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:14:58 2017 -0700

    Update README.md

[33mcommit 8be4d8d24c3e8e11645b2138761a4ad1c49f2eff[m
Author: Joshua Bell <inexorabletash@gmail.com>
Date:   Fri Sep 15 13:14:11 2017 -0700

    Initial commit
