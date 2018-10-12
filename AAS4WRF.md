---
title: 'The Another Assimilation System for WRF-Chem (AAS4WRF): a new mass-conserving emissions preprocessor for WRF-Chem regional modelling'
tags:
  - WRF-Chem
  - NCL
  - atmospheric emissions 
  - air quality modelling
authors:
  - name: Angel L. Vara-Vela
    orcid: 0000-0002-4972-4486
    affiliation: 1 
  - name: Angel G. Muñoz
    affiliation: 2
  - name: Arturo Lomas
    affiliation: 3  
  - name: Mario E. Gavidia-Calderón
    affiliation: 1   
  - name: Sergio Ibarra-Espinosa
    affiliation: 1
  - name: Carlos Mario González Duque
    affiliation: 4   
  - name: Maria de Fátima Andrade
    affiliation: 1   
affiliations:
 - name: Department of Atmospheric Sciences, University of São Paulo, São Paulo, Brazil
   index: 1
 - name: International Research Institute for Climate and Society (IRI), Columbia University, New York, USA
   index: 2
 - name: Centro de Investigación de Meteorología Aeronáutica (CIMA), DGAC, Quito, Ecuador
   index: 3   
 - name: Hydraulic Engineering and Environmental Research Group (GTAIHA), Universidad Nacional de Colombia Sede Manizales, Manizales, Colombia
   index: 4     
date: 31 October 2018
bibliography: AAS4WRF.bib
---

# Summary

The Weather Research and Forecasting with Chemistry (``WRF-Chem``) community model (Grell et al., 2005) have been widely used for the study of pollutants transport, formation of secondary pollutants, as well as for the assessment of air quality policies implementation. A key factor to improve the WRF-Chem air quality simulations over urban areas is the representation of anthropogenic emission sources. There are several tools that are available to assist users in creating their own emissions based on global emissions information; however, there is no single tool that will construct local emissions input datasets for any particular domain at this time. Because the official emissions preprocessor is designed to work with domains located over North America, this work presents the Another Assimilation System for WRF-Chem (``AAS4WRF``), a NCL based mass-conserving emissions preprocessor designed to create WRF-Chem ready emissions files from local inventories on a lat/lon projection. AAS4WRF is appropriate to scale emission rates from both surface and elevated sources, providing the users an alternative way to assimilate their emissions to WRF-Chem. Since it was successfully tested for the first time for the city of Lima, Peru in 2014 (managed by SENAMHI, the National Weather Service of the country), several studies on air quality modelling have applied this open source utility to conduct their experimental air quality simulations (Gavidia-Calderón et al., 2018; Vara-Vela et al., 2018; Gonzalez et al., 2018; Vara-Vela et al., 2017; Vara-Vela et al., 2016; Hoshyaripour et al., 2016; Andrade et al., 2015). Two case studies performed in the metropolitan areas of Manizales and São Paulo in Colombia and Brazil, respectively, are here presented in order to analyse the influence of using local or global emission inventories in the representation of regulated air pollutants such as tropospheric ozone. Although AAS4WRF works with local emissions information at the moment, further work is being conducted to make it compatible with global/regional emissions data file format.

# Structure of input emissions

AAS4WRF requires that the user provides a file containing the gridded hourly emissions (``emissions.txt`` in this example). Each line of the file is required to have the following format:

| id  |  longitude  |  latitude  |  species_1  |  species_2  |  …  |  species_i  |  species_(i+1)  |  …  |  species_36  |
|:----|:------------|:-----------|:------------|:------------|:----|:------------|:----------------|:----|:-------------|

where:

id: grid point ID
latitude : grid point latitude
longitude: grid point longitude
species_i: ith-species; 36 specifies the number of species in the ``CBMZ-MOSAIC`` chemical mecanism (remember to use the right units: mol km-2 hr-1 for gases and µg m-3 m s-1 for aerosols). Complete with columns of ``0`` if data is not available.

There are nx*ny*nt lines in the file emissions.txt, arranged in blocks of time (each with length of nx*ny*1) as follows: longitude and latitude are periodic 1D strictly monotonically increasing and decreasing arrays, respectively, that have their components equally spaced at ``dx`` (same horizontal resolution as the WRF grid). As geo-referenced data, we recommend to use any kind of GIS software to build their emission files (e.g., the emission file emissions.txt used in this example was built using Quantum GIS). In addition, data frames produced by the R package ``eixport`` (Ibarra-Espinosa et al., 2018) can be used as input emissions for AAS4WRF.

# Usage

The AAS4WRF is a code written entirely in the NCAR Command Language (NCL, 2017), then the users only need to correctly build both NCL and NCAR Graphics, or install the available binaries for their platform. Prior to run AAS4WRF, the user must set up a namelist file called ``namelist.emiss``. The workflow for using AAS4WRF is listed below.

1. Run ``GEOGRID``, ``UNGRIB``, ``METGRID``, and ``REAL`` normally as a standard WRF-Chem simulation.
2. Enter the following information into the namelist.emiss: 

|  Variable Names  |   Description                                                                        |
|:-----------------|:-------------------------------------------------------------------------------------|
|&input_files      |                                                                                      |
|  wrf_dir         | = string; full path and name of ``wrfinput_d01``                                     |
|  emiss_dir       | = string; full path and name of emissions.txt                                        |
|------------------|--------------------------------------------------------------------------------------|
| &grid_points     |                                                                                      |
|  nx              | = integer; number of longitude points in emissions.txt                               |
|  ny              | = integer; number of latitude points in emissions.txt                                |
|  nt              | = integer; number of time points in emissions.txt                                    |
|  hemi            | = integer; hemisphere: NH→1; SH→-1                                                   |
|:-----------------|--------------------------------------------------------------------------------------|
|&time_control     |                                                                                      | 
|  sy              | = integer; start year                                                                |
|  sm              | = integer; start month                                                               |
|  sd              | = integer; start day                                                                 |
|  ey              | = integer; end year                                                                  |
|  em              | = integer; end month                                                                 |
|  ed              | = integer; end day                                                                   |
|------------------|--------------------------------------------------------------------------------------|
|&species_control  |                                                                                      | 
|  so2             | = integer; column number for so2                                                     |
|  no              | = integer; column number for no                                                      |
|  ...             | ...                                                                                  |
|  i               | = integer; column number for ith-species                                             |
|  ...             | ...                                                                                  |
|  ecc             | = integer; column number for ecc (36 specifies the number of species in CBMZ-MOSAIC) |

3. Run AAS4WRF by typing: ``ncl AAS4WRF.ncl``

* Input files: emissions.txt, wrfinput_d01 and namelist.emiss

* Output files: two different output files can be produced, depending on the choice for ``io_style_emisisons``:

⋅⋅⋅``wrfchemi_00z_d01`` and ``wrfchemi_12z_d01`` for io_style_emissions=1: Set nt to 24 in namelist.emiss, and run AAS4WRF (although the file emissions.txt has more than 24 times, the code will only read the first nx*ny*24 lines). We recommend the user to visualise the content of the output files to check that everything is working properly up to this point.⋅⋅

⋅⋅⋅Or⋅⋅

⋅⋅⋅``wrfchemi_d01_<date/time>`` for io_style_emissions=2: Set nt to 168 (maximum number of times in this example) and run AAS4WRF. If a shorter period is desired, make sure the number of days in the section &time_control is fixed accordingly. This version of AAS4WRF only works with entire days (no fractional days are managed by this program at the moment).⋅⋅

# Examples

The following two examples compare the WRF-Chem model performance in terms of tropospheric ozone for different emissions datasets, those derived from global models such as ``EDGAR`` and ``RETRO`` are scaled down into the domains using the emission preprocessors ``anthro_emiss`` and ``prep_chem_src`` (Freitas et al., 2011), while those derived from local information are scaled using the AAS4WRF. Spatial distributions of local and global emissions, as well as temporal variations of hourly ozone concentrations from observations and WRF-Chem simulations, are shown in Figs 1 and 2 for a case study in Manizales, Colombia and São Paulo, Brazil, respectively.

![spatial distribution of local and global nitric oxide emissions (top panels), and temporal variations of hourly ozone concentrations from observations and WRF-Chem simulations (bottom panels) for a case study in Manizales, Colombia.](https://github.com/alvv1986/AAS4WRF/blob/master/SaoPaulo.png)

![spatial distribution of local and global aldehyde emissions (top panels), and temporal variations of hourly ozone concentrations from observations and WRF-Chem simulations (bottom panels) for a case study in São Paulo, Brazil.](https://github.com/alvv1986/AAS4WRF/blob/master/SaoPaulo.png)

The use of local emissions information allowed significant improvements in the representation of tropospheric ozone, characterised by better performance metrics (e.g., González et al. (2018)), and underscores the importance of using consistent (mass-conserving) emission preprocessor tools, especially in medium-sized cities where application of high-resolution air quality models is scarce.

\pagebreak

# Acknowledgements

We acknowledge use of the WRF-Chem preprocessor tool anthro_emiss provided by the Atmospheric Chemistry Observations and Modeling Lab (ACOM) of NCAR.

# References

