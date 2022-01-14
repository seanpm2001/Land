# FT and NaN test for the structs
println();
@testset "Photosynthesis --- functions" begin
    for FT in [Float32, Float64]
        c3_set   = C3CLM(FT);
        c4_set   = C4CLM(FT);
        leaf_3   = Leaf{FT}();
        leaf_4   = Leaf{FT}();
        td_q10   = ClimaCache.Q10{FT}(1, 273.15, 1.7);
        envir    = AirLayer{FT}();
        fluo_set = c3_set.Flu;
        T        = rand(FT) + 298;
        glc      = FT(0.1);
        p_i      = rand(FT) + 20;

        # temperature corrections
        leaf_temperature_dependence!(c3_set, leaf_3, envir, T);
        leaf_temperature_dependence!(c4_set, leaf_4, envir, T);

        # rubisco limited rates
        PhotosynthesisOld.rubisco_limited_rate!(c3_set, leaf_3);
        PhotosynthesisOld.rubisco_limited_rate!(c4_set, leaf_4);
        @test NaN_test(leaf_3);
        @test NaN_test(leaf_4);
        PhotosynthesisOld.rubisco_limited_rate!(c3_set, leaf_3, envir);
        @test NaN_test(leaf_3);

        # light limited rates
        PhotosynthesisOld.leaf_ETR!(c3_set, leaf_3);
        PhotosynthesisOld.leaf_ETR!(c4_set, leaf_4);
        PhotosynthesisOld.light_limited_rate!(c3_set, leaf_3);
        PhotosynthesisOld.light_limited_rate!(c4_set, leaf_4);
        @test NaN_test(leaf_3);
        @test NaN_test(leaf_4);
        PhotosynthesisOld.light_limited_rate!(c3_set, leaf_3, envir);
        @test NaN_test(leaf_3);

        # product limited rates
        PhotosynthesisOld.product_limited_rate!(c3_set, leaf_3);
        PhotosynthesisOld.product_limited_rate!(c4_set, leaf_4);
        @test NaN_test(leaf_3);
        @test NaN_test(leaf_4);
        PhotosynthesisOld.product_limited_rate!(c4_set, leaf_4, envir);
        @test NaN_test(leaf_4);

        # fluorescence
        leaf_photosynthesis!(c3_set, leaf_3, envir, PCO₂Mode(), FT(2));
        leaf_fluorescence!(fluo_set, leaf_3);
        leaf_photosynthesis!(c3_set, leaf_3, envir, GCO₂Mode());
        leaf_fluorescence!(fluo_set, leaf_3);
        @test NaN_test(leaf_3);

        # leaf photo from glc
        leaf_photosynthesis!(c3_set, leaf_3, envir, GCO₂Mode(), glc);
        leaf_photosynthesis!(c4_set, leaf_4, envir, GCO₂Mode(), glc);
        @test NaN_test(leaf_3);
        @test NaN_test(leaf_4);

        # leaf photo from p_i
        leaf_photosynthesis!(c3_set, leaf_3, envir, PCO₂Mode(), p_i);
        leaf_photosynthesis!(c4_set, leaf_4, envir, PCO₂Mode(), p_i);
        @test NaN_test(leaf_3);
        @test NaN_test(leaf_4);
    end
end
