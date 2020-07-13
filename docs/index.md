# RoutR

[RoutR][routr-github] is an R package for making input files for the Fortran version of the University of Washington (UW) hydrologic routing model ([Lohmann et al., 1998][lohmann1998]). The Fortran version of the UW routing model can be found [here][uwmodel-github]. (There is also an updated version called "[RVIC][rvic]," which has been adapted into Python.) RoutR is a collection of R functions I wrote to make inputs for, and analyze outputs from, the UW routing model.

The UW routing model is a linear routing scheme based on a simplified version of the Saint Venant equations. The model has six required input files and three optional input files. RoutR was designed to assist in creation of these input files.

### Required input files
* <b>Parameter file</b> - tells the routing model the names and locations of the different input and output files and the start and end time for the model run. It also tells the routing model where to save output files.
* **Flow direction file** - describes how water flows from one grid cell to another within the study area. The UW routing model uses a D8 flow direction convention with 1 being north, increasing clockwise.
* **Unit hydrograph file** - describes the unit hydrograph. A sample unit hydrograph is provided on the [VIC 4.2d documentation website][vic42d-docs].
* **Station location file** - tells the routing model where to calculate streamflow.
* **Fraction file** - determines which grid cells are included in the model run, and allows inclusion of fractions of grid cells.
* **Runoff (forcing) files** - The forcings for the UW routing model are runoff and baseflow fields (typically outputs from a land surface model, such as VIC).

Note that the UW routing model can be used with the ASCII-formatted outputs from the VIC-5 classic driver, after some small modifications to the VIC output files.

### Optional input files
* **Velocity file** - contains information about the flow velocity
* **xmask file** - related to the area of a grid cells
* **diff file** - flow diffusion file. Contains the flow diffusion parameter.

See the official [VIC 4.2d documentation website][vic42d-docs] for further details. While RoutR is helpful for creating input files for the UW routing model, users are encouraged to read the official documentation, as well. 

## Installation
RoutR is an R package and can be installed from Github via the R command `install_github`, from the `devtools` package. Also, the `raster` and `rgdal` packages are required. 

```r
library(devtools)
install_github("https://github.com/jschap1/routR")
```

## Recommended software

* GRASS GIS - for delineating watersheds and creating the flow direction file
* Flow Direction Toolkit - for making manual adjustments to the flow direction file

[uwmodel-github]:https://github.com/UW-Hydro/VIC_Routing
[rvic]:https://github.com/UW-Hydro/RVIC
[lohmann1998]:https://www.tandfonline.com/doi/abs/10.1080/02626669809492107
[vic42d-docs]:https://vic.readthedocs.io/en/vic.4.2.d/Documentation/Routing/RoutingInput/
[routr-github]:https://github.com/jschap1/routR

<!-- Help: 
https://www.mkdocs.org/
https://www.mkdocs.org/user-guide/deploying-your-docs/
 -->

<!-- ## Commands

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs help` - Print this help message.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files. -->
