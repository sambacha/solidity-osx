
### macosx && solidity: notes 


```bash
 ./webthree-helpers/scripts/ethbuild.sh --no-git --xcode --project solidity --all --cores 4 -DEVMJIT=0
 ```
##### `hiesenbug`
https://github.com/ethereum/webthree-umbrella/issues/565

##### `general issues `

https://github.com/ethereum/solidity/issues/36 <br>
https://github.com/ethereum/solidity/issues/569 <br>
https://github.com/ethereum/solidity/issues/367 <br>
https://github.com/ethereum/solc-bin/pull/21 <br>
https://github.com/ethereum/solc-bin/pull/76 <br>
https://github.com/ethereum/solidity/issues/7814 <br>
https://github.com/ethereum/solidity/issues/8860 <br>
https://github.com/ethereum/solidity/issues/8543 <br>

https://github.com/ethereum/solidity/pull/11166 <br>

https://github.com/ethereum/solidity/pull/9715 <br> 
https://github.com/ethereum/solidity/pull/9715/files/5f7b4a2e059d616e7c721c3576483b6a30e9590b <br>


####  `Version: 0.5.17+commit.d19bba13.Darwin.appleclang`

> * I haven't checked Windows binaries.
>   
>   * Except that 0.4.15 is known to report the wrong version so it
likely produces different bytecode too (#9545).
> * All other binaries on versions >= 0.3.6 produce identical bytecode.
> 
> So now getting the binaries out is just a matter of
[ethereum/solc-bin#76](https://github.com/ethereum/solc-bin/pull/76)
passing review. After it's merged anyone who needs the old ones for
verification will still be able to get them from the commit I tagged as
>
[`macosx-binaries-reporting-wrong-versions`](https://github.com/ethereum/solc-bin/releases/tag/macosx-binaries-reporting-wrong-versions).

> Sorry it took so long but I'm finally done with verifying the rebuilt
binaries. Running the bytecode comparison on the historical binaries
required adding extra functionality to our scripts and also making them
backwards compatible with the CLI interface of older versions. I'm glad
I did it because it turned out that there are more problems than just
the macOS binaries and that binaries for 0.3.6, 0.4.7 and 0.4.8 won't
produce the same bytecode even after the rebuild.
> 
> So here's the overview of the situation:
> 
> * Emscripten binaries for version 0.3.6 were not built from the exact
commit which is tagged as `v0.3.6` so they have a different version
string and produce different bytecode than the macOS binary: #10846.
> * The problem with 0.4.7 and 0.4.8: #10841. In short, these versions
include platform name in version string so you have to use the same
platform if you want the bytecode to be reproducible. I recommend just
not using native binaries with these versions. This was fixed in 0.4.9
and up. Versions below 0.4.6 and down do not include metadata hash in
the produced bytecode so it's not an issue for them.
> * Linux binaries for 0.4.10 (#10839) and 0.4.26 (#10840) do not
produce the same bytecode as other platforms. The problem with 0.4.10 is
fixable by rebuilding the binary. 0.4.26 is weirder (there was a
difference but just in a single test case out of ~1840 and only with
optimizer enabled) but maybe a rebuild would help there too.
> * I haven't checked Windows binaries.
>   
>   * Except that 0.4.15 is known to report the wrong version so it
likely produces different bytecode too (#9545).
> * All other binaries on versions >= 0.3.6 produce identical bytecode.
> 
> So now getting the binaries out is just a matter of
[ethereum/solc-bin#76](https://github.com/ethereum/solc-bin/pull/76)
passing review. After it's merged anyone who needs the old ones for
verification will still be able to get them from the commit I tagged as
>
[`macosx-binaries-reporting-wrong-versions`](https://github.com/ethereum/solc-bin/releases/tag/macosx-binaries-reporting-wrong-versions).

_Originally posted by @cameel in
https://github.com/ethereum/solidity/issues/10183#issuecomment-720739881_


> Turns out that #10846 is not the only issue with the macOS binary for
0.3.6:
> 
> * It's not actually using the same commit hash as `v0.3.6` (probably
ignoring `commit_hash.txt`) unlike 0.4.x and above.
> * There are a few input files for which it fails and emscripten binary
does not or the other way around.
> 
> Since it's such an old version and resolving these issues will be
pretty tedious I think it's not really worth it. So the question would
be whether we should keep such a binary in `solc-bin` or is it better to
remove it? It still produces valid bytecode and is fully usable. It's
just that you won't be able to verify its output using the emscripten
binary (and that only if you're using libraries; contracts are fine).
> 
> @alcuadrado Do you have an opinion on that?


> Sorry it took so long but I'm finally done with verifying the rebuilt
binaries. Running the bytecode comparison on the historical binaries
required adding extra functionality to our scripts and also making them
backwards compatible with the CLI interface of older versions. I'm glad
I did it because it turned out that there are more problems than just
the macOS binaries and that binaries for 0.3.6, 0.4.7 and 0.4.8 won't
produce the same bytecode even after the rebuild.
> 
> So here's the overview of the situation:
> 
> * Emscripten binaries for version 0.3.6 were not built from the exact
commit which is tagged as `v0.3.6` so they have a different version
string and produce different bytecode than the macOS binary: #10846.
> * The problem with 0.4.7 and 0.4.8: #10841. In short, these versions
include platform name in version string so you have to use the same
platform if you want the bytecode to be reproducible. I recommend just
not using native binaries with these versions. This was fixed in 0.4.9
and up. Versions below 0.4.6 and down do not include metadata hash in
the produced bytecode so it's not an issue for them.
> * Linux binaries for 0.4.10 (#10839) and 0.4.26 (#10840) do not
produce the same bytecode as other platforms. The problem with 0.4.10 is
fixable by rebuilding the binary. 0.4.26 is weirder (there was a
difference but just in a single test case out of ~1840 and only with
optimizer enabled) but maybe a rebuild would help there too.
