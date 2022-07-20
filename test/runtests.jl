using ClimaCache
using PkgUtility
using Test


@testset verbose = true "ClimaCache Test" begin
    @testset "Soil" begin
        for FT in [Float32, Float64]
            soil1 = ClimaCache.Soil{FT}(ZS = FT[0,-1]);
            for soil in [soil1]
                @test FT_test(soil, FT);
                @test NaN_test(soil);
            end;
        end;
    end;

    @testset "Air" begin
        for FT in [Float32, Float64]
            air = ClimaCache.AirLayer{FT}();
            @test FT_test(air, FT);
            @test NaN_test(air);
        end;
    end;

    @testset "Plant" begin
        for FT in [Float32, Float64]
            # Pressure volume curve
            pvc1 = ClimaCache.LinearPVCurve{FT}();
            pvc2 = ClimaCache.SegmentedPVCurve{FT}();
            for pvc in [pvc1, pvc2]
                @test FT_test(pvc, FT);
                @test NaN_test(pvc);
            end;

            # Plant hydraulic system
            lhs1 = ClimaCache.LeafHydraulics{FT}();
            lhs2 = ClimaCache.LeafHydraulics{FT}(FLOW = ClimaCache.NonSteadyStateFlow{FT}(DIM_CAPACITY = 1));
            rhs1 = ClimaCache.RootHydraulics{FT}();
            rhs2 = ClimaCache.RootHydraulics{FT}(FLOW = ClimaCache.NonSteadyStateFlow{FT}(DIM_CAPACITY = 5));
            shs1 = ClimaCache.StemHydraulics{FT}();
            shs2 = ClimaCache.StemHydraulics{FT}(FLOW = ClimaCache.NonSteadyStateFlow{FT}(DIM_CAPACITY = 5));
            for hs in [lhs1, lhs2, rhs1, rhs2, shs1, shs2]
                @test FT_test(hs, FT);
                @test NaN_test(hs);
            end;

            # Root and Stem
            root = ClimaCache.Root{FT}();
            stem = ClimaCache.Stem{FT}();
            for hs in [root, stem]
                @test FT_test(hs, FT);
                @test NaN_test(hs);
            end;

            # Leaf
            leaf_c3 = ClimaCache.Leaf{FT}("C3");
            leaf_c4 = ClimaCache.Leaf{FT}("C4");
            leaf_cy = ClimaCache.Leaf{FT}("C3Cytochrome");
            for leaf in [leaf_c3, leaf_c4, leaf_cy]
                @test FT_test(leaf, FT);
                # NaN test will not pass because of the NaNs in temperature dependency structures
                # @test NaN_test(leaf);
            end;

            # Leaves1D
            leaves_c3 = ClimaCache.Leaves1D{FT}("C3");
            leaves_c4 = ClimaCache.Leaves1D{FT}("C4");
            leaves_cy = ClimaCache.Leaves1D{FT}("C3Cytochrome");
            for leaves in [leaves_c3, leaves_c4, leaves_cy]
                @test FT_test(leaves, FT);
                # NaN test will not pass because of the NaNs in temperature dependency structures
                # @test NaN_test(leaf);
            end;

            # Leaves2D
            leaves_c3 = ClimaCache.Leaves2D{FT}("C3");
            leaves_c4 = ClimaCache.Leaves2D{FT}("C4");
            leaves_cy = ClimaCache.Leaves2D{FT}("C3Cytochrome");
            for leaves in [leaves_c3, leaves_c4, leaves_cy]
                @test FT_test(leaves, FT);
                # NaN test will not pass because of the NaNs in temperature dependency structures
                # @test NaN_test(leaf);
            end;

            # LeafBiophysics
            lbio1 = ClimaCache.HyperspectralLeafBiophysics{FT}();
            lbio2 = ClimaCache.BroadbandLeafBiophysics{FT}();
            for lbio in [lbio1, lbio2]
                @test FT_test(lbio, FT);
                @test NaN_test(lbio);
            end;

            # Fluorescence model
            vdt1 = ClimaCache.VDTModelAll(FT);
            vdt2 = ClimaCache.VDTModelDrought(FT);
            for vdt in [vdt1, vdt2]
                @test FT_test(vdt, FT);
                @test NaN_test(vdt);
            end;

            # Reaction center
            rc1 = ClimaCache.VJPReactionCenter{FT}();
            rc2 = ClimaCache.CytochromeReactionCenter{FT}();
            for rc in [rc1, rc2]
                @test FT_test(rc, FT);
                @test NaN_test(rc);
            end;

            # Photosynthesis model
            cy_1 = ClimaCache.C3CytochromeModel{FT}();
            cy_2 = ClimaCache.C3CytochromeModel{FT}(COLIMIT_CJ = ClimaCache.ColimitCJCLMC3(FT), COLIMIT_IP = ClimaCache.ColimitIPCLM(FT));
            c3_1 = ClimaCache.C3VJPModel{FT}();
            c3_2 = ClimaCache.C3VJPModel{FT}(COLIMIT_CJ = ClimaCache.ColimitCJCLMC3(FT), COLIMIT_IP = ClimaCache.ColimitIPCLM(FT), COLIMIT_J = ClimaCache.ColimitJCLM(FT));
            c4_1 = ClimaCache.C4VJPModel{FT}();
            c4_2 = ClimaCache.C4VJPModel{FT}(COLIMIT_CJ = ClimaCache.ColimitCJCLMC4(FT), COLIMIT_IP = ClimaCache.ColimitIPCLM(FT));
            for st in [cy_1, cy_2, c3_1, c3_2, c4_1, c4_2]
                for rc in [rc1, rc2]
                    @test FT_test(st, FT);
                    # NaN test will not pass because of the NaNs in temperature dependency structures
                    # @test NaN_test(st);
                end;
            end;

            # Mode and colimitations
            mod1 = ClimaCache.GCO₂Mode();
            mod2 = ClimaCache.PCO₂Mode();
            col1 = ClimaCache.MinimumColimit{FT}();
            col2 = ClimaCache.QuadraticColimit{FT}(0.98);
            col3 = ClimaCache.SerialColimit{FT}();
            for st in [mod1, mod2, col1, col2, col3]
                for rc in [rc1, rc2]
                    @test FT_test(st, FT);
                    @test NaN_test(st);
                end;
            end;

            # Temperature dependency
            td_1 = ClimaCache.Arrhenius{FT}(298.15, 41.0, 79430.0);
            td_2 = ClimaCache.ArrheniusPeak{FT}(298.15, 1.0, 57500.0, 439000.0, 1400.0);
            td_3 = ClimaCache.Q10{FT}(298.15, 0.0140/8760, 1.4);
            for td in [td_1, td_2, td_3]
                @test FT_test(td, FT);
                @test NaN_test(td);
            end;

            # Beta function
            param_1 = ClimaCache.BetaParameterKleaf();
            param_2 = ClimaCache.BetaParameterKsoil();
            param_3 = ClimaCache.BetaParameterPleaf();
            param_4 = ClimaCache.BetaParameterPsoil();
            param_5 = ClimaCache.BetaParameterΘ();
            param_y = ClimaCache.BetaParameterG1();
            param_z = ClimaCache.BetaParameterVcmax();
            for p_y in [param_y, param_z]
                for p_x in [param_1, param_2, param_3, param_4, param_5]
                    β = ClimaCache.BetaFunction{FT}(PARAM_X = p_x, PARAM_Y = p_y);
                    @test FT_test(β, FT);
                    @test NaN_test(β);
                end;
            end;

            # Stomatal Models
            sm_1 = ClimaCache.BallBerrySM{FT}();
            sm_2 = ClimaCache.GentineSM{FT}();
            sm_3 = ClimaCache.LeuningSM{FT}();
            sm_4 = ClimaCache.MedlynSM{FT}();
            sm_5 = ClimaCache.AndereggSM{FT}();
            sm_6 = ClimaCache.EllerSM{FT}();
            sm_7 = ClimaCache.SperrySM{FT}();
            sm_8 = ClimaCache.WangSM{FT}();
            sm_9 = ClimaCache.Wang2SM{FT}();
            for sm in [sm_1, sm_2, sm_3, sm_4, sm_5, sm_6, sm_7, sm_8, sm_9]
                @test FT_test(sm, FT);
                @test NaN_test(sm);
            end;
        end;
    end;

    @testset "Radiation" begin
        for FT in [Float32, Float64]
            # Wave length sets
            wls1 = ClimaCache.WaveLengthSet{FT}();
            wls2 = ClimaCache.WaveLengthSet{FT}(DATASET = ClimaCache.LAND_2017);
            for wls in [wls1, wls2]
                @test FT_test(wls, FT);
                # NaN test will not pass because of the NaNs in wls2
                # @test NaN_test(wls);
            end;

            # Solar radiation
            rad1 = ClimaCache.BroadbandRadiation{FT}();
            rad2 = ClimaCache.HyperspectralRadiation{FT}();
            for rad in [rad1, rad2]
                @test FT_test(rad, FT);
                @test NaN_test(rad);
            end;

            # Sun-sensor geometry
            ssg = ClimaCache.SunSensorGeometry{FT}();
            @test FT_test(ssg, FT);
            @test NaN_test(ssg);

            # Canopy structure
            can = ClimaCache.HyperspectralMLCanopy{FT}();
            @test FT_test(can, FT);
            @test NaN_test(can);
        end;
    end;

    @testset "SPAC" begin
        for FT in [Float32, Float64]
            spac1 = ClimaCache.MonoElementSPAC{FT}();
            spac2 = ClimaCache.MonoMLGrassSPAC{FT}();
            spac3 = ClimaCache.MonoMLPalmSPAC{FT}();
            spac4 = ClimaCache.MonoMLTreeSPAC{FT}();
            for spac in [spac1, spac2, spac3, spac4]
                @test FT_test(spac, FT);
                # NaN test will not pass because of the NaNs in temperature dependency structures
                # @test NaN_test(wls);
            end;
        end;
    end;
end;
