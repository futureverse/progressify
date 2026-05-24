# List packages and functions supporting progressification

List packages and functions supporting progressification

## Usage

``` r
progressify_supported_packages()

progressify_supported_functions(package)
```

## Arguments

- package:

  A package name.

## Value

A character vector of package or function names.

## Examples

``` r
pkgs <- progressify_supported_packages()
pkgs
#>  [1] "base"         "boot"         "crossmap"     "doFuture"     "foreach"     
#>  [6] "furrr"        "future.apply" "fwb"          "partykit"     "plyr"        
#> [11] "purrr"        "sandwich"     "stats"       

fcns <- progressify_supported_functions("base")
print(fcns)
#>  [1] ".mapply"   "Map"       "apply"     "by"        "eapply"    "lapply"   
#>  [7] "mapply"    "replicate" "sapply"    "tapply"    "vapply"   

if (requireNamespace("purrr")) {
  fcns <- progressify_supported_functions("purrr")
  print(fcns)
}
#>  [1] "imap"     "imap_chr" "imap_dbl" "imap_int" "imap_lgl" "imap_vec"
#>  [7] "imodify"  "map"      "map2"     "map2_chr" "map2_dbl" "map2_int"
#> [13] "map2_lgl" "map2_vec" "map_chr"  "map_dbl"  "map_int"  "map_lgl" 
#> [19] "map_vec"  "modify"   "modify2"  "pmap"     "pmap_chr" "pmap_dbl"
#> [25] "pmap_int" "pmap_lgl" "pmap_vec" "pwalk"    "walk"     "walk2"   
```
