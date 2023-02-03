{-# LANGUAGE CPP #-}
module Main (main) where

#ifdef VERSION_criterion
import Criterion
import Criterion.Main
#endif

#ifdef VERSION_tasty_bench
import Test.Tasty.Bench
#endif

import Concurrency
import Countdown
import FileSizes
import Unlift

main :: IO ()
main = defaultMain
  [ concurrencyBenchmark
  , unliftBenchmark
  , bgroup "countdown" $ map countdown [1000, 2000, 3000]
  , bgroup "filesize"  $ map filesize  [1000, 2000, 3000]
  ]

countdown :: Integer -> Benchmark
countdown n = bgroup (show n)
  [ bgroup "effectful (local/static)"
    [ bench "deep"    $ nf countdownEffectfulLocalDeep n
    ]
  ]

filesize :: Int -> Benchmark
filesize n = bgroup (show n)
  [ bench "reference" $ nfAppIO ref_calculateFileSizes (take n files)
  , bgroup "effectful"
    [ bench "shallow" $ nfAppIO effectful_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO effectful_calculateFileSizesDeep (take n files)
    ]
#ifdef VERSION_cleff
  , bgroup "cleff"
    [ bench "shallow" $ nfAppIO cleff_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO cleff_calculateFileSizesDeep (take n files)
    ]
#endif
#ifdef VERSION_freer_simple
  , bgroup "freer-simple"
    [ bench "shallow" $ nfAppIO fs_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO fs_calculateFileSizesDeep (take n files)
    ]
#endif
#ifdef VERSION_eff
  , bgroup "eff"
    [ bench "shallow" $ nfAppIO eff_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO eff_calculateFileSizesDeep (take n files)
    ]
#endif
#ifdef VERSION_mtl
  , bgroup "mtl"
    [ bench "shallow" $ nfAppIO mtl_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO mtl_calculateFileSizesDeep (take n files)
    ]
#endif
#ifdef VERSION_fused_effects
  , bgroup "fused-effects"
    [ bench "shallow" $ nfAppIO fe_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO fe_calculateFileSizesDeep (take n files)
    ]
#endif
#ifdef VERSION_polysemy
  , bgroup "polysemy"
    [ bench "shallow" $ nfAppIO poly_calculateFileSizes (take n files)
    , bench "deep"    $ nfAppIO poly_calculateFileSizesDeep (take n files)
    ]
#endif
  ]
  where
    files :: [FilePath]
    files = repeat "effectful.cabal"
