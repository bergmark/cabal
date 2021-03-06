module PackageTests.BuildDeps.InternalLibrary2.Check where

import qualified Data.ByteString.Char8 as C
import PackageTests.PackageTester
import System.FilePath
import Test.Tasty.HUnit


suite :: FilePath -> FilePath -> Assertion
suite ghcPath ghcPkgPath = do
    let spec = PackageSpec
            { directory = "PackageTests" </> "BuildDeps" </> "InternalLibrary2"
            , configOpts = []
            , distPref = Nothing
            }
    let specTI = PackageSpec
            { directory = directory spec </> "to-install"
            , configOpts = []
            , distPref = Nothing
            }

    unregister "InternalLibrary2" ghcPkgPath
    iResult <- cabal_install specTI ghcPath
    assertInstallSucceeded iResult
    bResult <- cabal_build spec ghcPath
    assertBuildSucceeded bResult
    unregister "InternalLibrary2" ghcPkgPath

    (_, _, output) <- run (Just $ directory spec) (directory spec </> "dist" </> "build" </> "lemon" </> "lemon") [] []
    C.appendFile (directory spec </> "test-log.txt") (C.pack $ "\ndist/build/lemon/lemon\n"++output)
    assertEqual "executable should have linked with the internal library" "myLibFunc internal" (concat $ lines output)
