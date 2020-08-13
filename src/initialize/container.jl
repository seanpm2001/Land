###############################################################################
#
# Create RTContainer
#
###############################################################################
"""
    create_rt_container(can::Canopy4RT{FT}, can_opt::CanopyOpticals{FT}, angles::SolarAngles{FT}, wl_set::WaveLengths{FT}) where {FT<:AbstractFloat}

Create an [`RTContainer`](@ref), given
- `can` [`Canopy4RT`](@ref) type struct, providing canopy structure information
- `can_opt` [`CanopyOpticals`](@ref) type, where optical properties is stored
- `angles` [`SolarAngles`](@ref) type struct, defining sun-sensor geometry
- `soil_opt` [`SoilOpticals`](@ref) type struct for soil optical properties
- `wl_set` [`WaveLengths`](@ref) type struct
"""
function create_rt_container(
            can::Canopy4RT{FT},
            can_opt::CanopyOpticals{FT},
            angles::SolarAngles{FT},
            soil_opt::SoilOpticals{FT},
            wl_set::WaveLengths{FT}
) where {FT<:AbstractFloat}
    @unpack psi = angles;
    @unpack lazitab, litab = can;
    @unpack nAzi, nIncl, nLayer, nWL, sigb = can_opt;
    @unpack albedo_SW = soil_opt;
    @unpack dWL, iPAR, iWLE, iWLF, nWLE, nWLF, WL = wl_set;

    cos_ttlo  = cosd.(lazitab);
    cos_philo = cosd.(lazitab .- psi);
    cos_ttli  = cosd.(litab);
    sin_ttli  = sind.(litab);
    vol_scatt = ones(FT, 4);

    # for canopy_geometry!
    _Cs = cos_ttli .* 0; # [nli]
    _Ss = sin_ttli .* 0; # [nli]
    _Co = cos_ttli .* 0; # [nli]
    _So = sin_ttli .* 0; # [nli]
    _1s = ones(FT,1,length(lazitab)); #[1, nlazi]
    cds = _Cs * _1s .+ _Ss * cos_ttlo' ; # [nli, nlazi]
    cdo = _Co * _1s .+ _So * cos_philo'; # [nli, nlazi]
    _2d = _Co * _1s                    ; # [nli, nlazi]

    # for short_wave!
    τ_dd   = sigb .* 0;
    τ_sd   = sigb .* 0;
    ρ_dd   = sigb .* 0;
    ρ_sd   = sigb .* 0;
    dnorm  = sigb[:,1] .* 0;
    piloc2 = sigb .* 0;
    piloc  = sigb[:,1] .* 0;
    pilos  = sigb[:,1] .* 0;
    pilo   = sigb[:,1] .* 0;

    # for canopy_fluxes!
    abs_wave    = zeros(nWL);
    absfs_lidf  = zeros(nAzi);
    lPs         = zeros(nLayer);
    kChlrel     = zeros( length(iPAR) );
    λ_iPAR      = WL[iPAR];
    dλ_iPAR     = dWL[iPAR];
    dλ_iWlE     = dWL[iWLE];
    E_iPAR      = zeros( length(iPAR) );
    E_all       = zeros( length(dWL ) );
    PAR_diff    = zeros( length(iPAR) );
    PAR_dir     = zeros( length(iPAR) );
    PAR_diffCab = zeros( length(iPAR) );
    PAR_dirCab  = zeros( length(iPAR) );
    abs_iPAR    = zeros( length(iPAR) );

    # for sif_fluxes!
    soil_sif_albedo = albedo_SW[iWLF];
    τ_dd_sif        = sigb[iWLF,:] .* 0;
    ρ_dd_sif        = sigb[iWLF,:] .* 0;
    S⁻              = zeros(FT, (nWLF,nLayer));
    S⁺              = deepcopy(S⁻);
    piLs            = deepcopy(S⁻);
    piLd            = deepcopy(S⁻);
    Fsmin           = deepcopy(S⁻);
    Fsplu           = deepcopy(S⁻);
    Fdmin           = deepcopy(S⁻);
    Fdplu           = deepcopy(S⁻);
    Femo            = deepcopy(S⁻);
    M⁺              = zeros(FT, (nWLF,nWLE));
    M⁻              = zeros(FT, (nWLF,nWLE));
    M⁻_sun          = zeros(FT, nWLF);
    M⁺_sun          = zeros(FT, nWLF);
    wfEs            = zeros(FT, nWLF);
    sfEs            = zeros(FT, nWLF);
    sbEs            = zeros(FT, nWLF);
    M⁺⁻             = zeros(FT, nWLF);
    M⁺⁺             = zeros(FT, nWLF);
    M⁻⁺             = zeros(FT, nWLF);
    M⁻⁻             = zeros(FT, nWLF);
    sun_dwl_iWlE    = zeros(FT, nWLE);
    tmp_dwl_iWlE    = zeros(FT, nWLE);
    ϕ_cosΘ          = zeros(FT, (nIncl,nAzi));
    ϕ_cosΘ_lidf     = zeros(FT, nAzi);
    vfEplu_shade    = zeros(FT, nWLF);
    vbEmin_shade    = zeros(FT, nWLF);
    vfEplu_sun      = zeros(FT, nWLF);
    vbEmin_sun      = zeros(FT, nWLF);
    sigfEmin_shade  = zeros(FT, nWLF);
    sigbEmin_shade  = zeros(FT, nWLF);
    sigfEmin_sun    = zeros(FT, nWLF);
    sigbEmin_sun    = zeros(FT, nWLF);
    sigfEplu_shade  = zeros(FT, nWLF);
    sigbEplu_shade  = zeros(FT, nWLF);
    sigfEplu_sun    = zeros(FT, nWLF);
    sigbEplu_sun    = zeros(FT, nWLF);
    zeroB           = zeros(FT, nWLF);
    F⁻              = zeros(FT, (nWLF, nLayer+1));
    F⁺              = zeros(FT, (nWLF, nLayer+1));
    net_diffuse     = deepcopy(τ_dd_sif);
    tmp_1d_nWlF     = zeros(FT, nWLF);
    tmp_1d_nLayer   = zeros(FT, nLayer);
    tmp_2d_nWlF_nLayer   = zeros(FT, (nWLF,nLayer));
    tmp_2d_nWlF_nLayer_2 = zeros(FT, (nWLF,nLayer));

    return RTContainer{FT}(cos_ttlo,
                           cos_philo,
                           cos_ttli,
                           sin_ttli,
                           vol_scatt,
                           _Cs,
                           _Ss,
                           _Co,
                           _So,
                           _1s,
                           cds,
                           cdo,
                           _2d,
                           τ_dd,
                           τ_sd,
                           ρ_dd,
                           ρ_sd,
                           dnorm,
                           pilo,
                           piloc2,
                           piloc,
                           pilos,
                           abs_wave,
                           absfs_lidf,
                           lPs,
                           kChlrel,
                           λ_iPAR,
                           dλ_iPAR,
                           dλ_iWlE,
                           E_iPAR,
                           E_all,
                           PAR_diff,
                           PAR_dir,
                           PAR_diffCab,
                           PAR_dirCab,
                           soil_sif_albedo,
                           τ_dd_sif,
                           ρ_dd_sif,
                           S⁻,
                           S⁺,
                           piLs,
                           piLd,
                           Fsmin,
                           Fsplu,
                           Fdmin,
                           Fdplu,
                           Femo,
                           M⁺,
                           M⁻,
                           M⁻_sun,
                           M⁺_sun,
                           wfEs,
                           sfEs,
                           sbEs,
                           M⁺⁻,
                           M⁺⁺,
                           M⁻⁺,
                           M⁻⁻,
                           sun_dwl_iWlE,
                           tmp_dwl_iWlE,
                           ϕ_cosΘ,
                           ϕ_cosΘ_lidf,
                           vfEplu_shade,
                           vbEmin_shade,
                           vfEplu_sun,
                           vbEmin_sun,
                           sigfEmin_shade,
                           sigbEmin_shade,
                           sigfEmin_sun,
                           sigbEmin_sun,
                           sigfEplu_shade,
                           sigbEplu_shade,
                           sigfEplu_sun,
                           sigbEplu_sun,
                           zeroB,
                           F⁻,
                           F⁺,
                           net_diffuse,
                           tmp_1d_nWlF,
                           tmp_1d_nLayer,
                           tmp_2d_nWlF_nLayer,
                           tmp_2d_nWlF_nLayer_2)
end
