module LeafEnergyWaterBalanceMod
####
#### Surface energy balance
####

include("LeafPhotosynthesisMod.jl")

export LeafEnergyWaterBalance

"""
# compute surface energy balance of a leaf Rn-H-LE=0
# Arguments
- `met::meteo`: meteorological forcing.
- `Ts_t::Float32`: Leaf temperature forcing.
- `T::Number`: Leaf Temperature
"""
function LeafEnergyWaterBalance(Tleaf, psileaf, Cc, met::meteo, l::leaf_params,  flux::fluxes, psi_s)
    # plugged Tleaf and psileaf outside of l as they are being iterated during fine time stepping - rest assumed constant
    # find solution to the surface energy LeafEnergyBalance, with a small thermal inertia: C dT/dt = Rn-H-LE and water balance of a leaf d.dH20/dt = Sap - T
    # first set parameter values that are assumed not to be changing with energy budget
    l.T            = Tleaf;
    l.psi_l        = psileaf;
    l.Cc           = Cc;

    if(Tleaf<200.0 || psileaf>0.0)
        println("Error in Tleaf and psi_leaf - unphysical values")
        process.exit(10)
    end
    LeafPhotosynthesis!(flux, l, met); # compute H, LE in there as well


    # TODO aerodynamic resistance should be double for the sensible heat flux at leaf level, but do we really care?
    l.Cleaf = l.LMA* ( (1.0-l.RWC)*physcon.Cdryleaf + l.RWC*physcon.Cpl )/(1.0-l.RWC); # leaf conductivity
    # println("Cleaf=",l.Cleaf)
    lv           =   Lv(Tleaf);
    flux.Rn      =   (1-l.α)*met.S_down +  2.0*(met.L_down - l.ε*physcon.σ*Tleaf^4); # 2 is for two sides of the leaves
    #println("S_down=",met.S_down," , Ldown=",met.L_down," Tleaf=",Tleaf)
    #dRn_dTs = - 4*l.ε*physcon.σ*Tleaf^3;
    setkx!(l,psi_s, psileaf) ;# set hydraulic conductivity as a function of psis and psi_l
    flux.Sap     =   (psi_s - l.psi_l)*l.kx *μ_l(Tleaf)/μ_l(273.15+20.0); # equal to int k(psi)dpsi; includes kinematic effects
    dT_dt        =   (flux.Rn-flux.H-flux.LE)/l.Cleaf; # 2 times for up and down part of the leaves - TODO need to check this I am not sure I agree when integrated over the canopy
    dH2Ol_dt     =   (flux.Sap-flux.LE/lv)/l.Ctree;
    dt           =   1.0; # one second time step for Cc - a bit arbitrary and not cruCcal but will be cahnged later for actual airspace
    dCc_dt       =   (flux.An_diffusion - flux.An_biochemistry) / dt; #(l.Chloroplast_rel_volume*l.dleaf*l.LAI);
    #println("Cc/(dCc/dt)=",1.0/(dCc_dt/l.Cc)," An_biochemistry=",flux.An_biochemistry," An_diffusion=",flux.An_diffusion)

    print(flux.Cs, " ppm, ", l.VPD/1000.0, " (kPA), ", flux.An_biochemistry, " micromol/s/m2  "," An_diffusion=",flux.An_diffusion)
    #println("Sdown= " , met.S_down, "W/m2, Rn=",flux.Rn,"W/m2, SEB=",flux.Rn-flux.H-flux.LE,"W/m2, H= ",flux.H, "W /m2, LE= ",flux.LE, "W /m2, dT_dt=",dT_dt*3600," (K/hr), ra=",flux.ra, " (s/m) ")
    return dT_dt, dH2Ol_dt, dCc_dt
end

end # end module