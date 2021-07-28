within ;
package DP_ferkl_ECMO

  model ECMOSim
    //Typy přenosového media
        replaceable package Blood =
          Physiolibrary.Media.BloodBySiggaardAndersen annotation(choicesAllMatching=True);
      replaceable package Air =
          Physiolibrary.Media.Air annotation(choicesAllMatching=True);

    // Parametry pacienta
      parameter Real Shunts=0.02;
      parameter Physiolibrary.Types.HydraulicConductance StarlingLeft=
        1.250102626409427e-07*(5/4)                                        "Slope of starling curve [m3/(Pa.s)]";
      parameter Physiolibrary.Types.HydraulicConductance StarlingRight=
        1.250102626409427e-07*(5/4)                                         "Slope of starling curve [m3/(Pa.s)]";
      //parameter Physiolibrary.Types.VolumeFlowRate SF=8.3333333333333e-05
       //                                                         "Systemic blood flow [m3/s]";

      parameter Physiolibrary.Types.Frequency RR=15/60 "Respiration rate [s-1]";
      parameter Physiolibrary.Types.Volume TV=0.0005
                                                  "Tidal volume [m3]";
      parameter Physiolibrary.Types.Volume DV=0.00015
                                                   "Dead space volume [m3]";
      parameter Physiolibrary.Types.HydraulicConductance C_shunt=1.250102626409427e-07
        *((Shunts*(1/3)))                          "Conductance of shunt [m3/(Pa.s)]";
      parameter Physiolibrary.Types.HydraulicConductance C_ventilation=
        1.019716212977928e-05*((1/1.5)) "Conductance of ventilation [m3/(Pa.s)]";
      parameter Physiolibrary.Types.HydraulicConductance C_cirkulation=1.250102626409427e-07
        *(1/3*(1 - Shunts))                          "Conductance of circulation [m3/(Pa.s)]";
      parameter Physiolibrary.Types.MolarFlowRate O2BMR=0.00032233333333333
                                                                        " [mol/s]";
      parameter Physiolibrary.Types.MolarFlowRate CO2BMR=0.00025783333333333
                                                                         " [mol/s]";
    // Parametry ECMO

        parameter Real VAV=1   "Distribution of blood to veins and arteries, Values from 0 (100 % Veins) to 1(100 % Arteries";
  //       parameter Physiolibrary.Types.VolumeFlowRate ECMOF=0   "ECMO blood flow [m3/s]";
  //       parameter Physiolibrary.Types.VolumeFlowRate O2Flow=1.6666666666667e-05
  //                                                               "O2 flow in ECMO [m3/s]";
  //       parameter Physiolibrary.Types.VolumeFlowRate AirFlow=1.6666666666667e-05
  //                                                                      "Air flow in ECMO[m3/s]";
        parameter Real RPM=0    "Rotation per minute in ECMO pump";
        parameter Physiolibrary.Types.VolumeFlowRate SWEEP=0 "Air + O2 flow in ECMO[m3/s]";
        parameter Real FiO2=0.8       "Fraction of oxygen in gas";

    Physiolibrary.Fluid.Components.Resistor resistor1(redeclare package Medium
        = Blood, Resistance=7999343.2449*((5.5*20)/8))
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-160,-164})));
    Physiolibrary.Fluid.Components.ElasticVessel Arteries(
      redeclare package Medium = Blood,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.00085,
      Compliance(displayUnit="ml/mmHg") = 2.6627185942521e-08,
      ZeroPressureVolume(displayUnit="l") = 0.00045,
      nPorts=7) annotation (Placement(transformation(extent={{-116,-170},{-136,
              -148}})));
    Physiolibrary.Fluid.Components.ElasticVessel Veins(
      redeclare package Medium = Blood,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.00325,
      Compliance(displayUnit="ml/mmHg") = 6.1880080007267e-07,
      ZeroPressureVolume(displayUnit="l") = 0.00295,
      nPorts=8)
      annotation (Placement(transformation(extent={{-266,-172},{-246,-152}})));
    Physiolibrary.Fluid.Components.Resistor resistor2(redeclare package Medium
        = Blood, Resistance=7999343.2449*(20/8))                     annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-220,-164})));
    Physiolibrary.Fluid.Components.ElasticVessel Tissue(
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.0003,
      useThermalPort=true,
      Compliance(displayUnit="ml/mmHg") = 3.0002463033826e-08,
      ZeroPressureVolume(displayUnit="l") = 0.0002,
      nPorts=5) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-190,-248})));
    Physiolibrary.Fluid.Sensors.PressureMeasure PressureCapilarsBody(redeclare
        package Medium = Blood)
      annotation (Placement(transformation(extent={{-262,-238},{-282,-218}})));
    Chemical.Sources.SubstanceInflowT CO2_in(
      SubstanceFlow(displayUnit="mmol/min") = CO2BMR,
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.CarbonDioxide_gas()) annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-120,-300})));
    Chemical.Sources.SubstanceOutflow O2_left(useSubstanceFlowInput=false,
        SubstanceFlow(displayUnit="mmol/min") = O2BMR) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-266,-300})));
    Physiolibrary.Fluid.Sensors.PartialPressure pO2_tissue(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.Oxygen_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{-276,-260},{-256,-280}})));
    Physiolibrary.Fluid.Sensors.PartialPressure pCO2_tissue(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.CarbonDioxide_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-118,-270})));
    Physiolibrary.Fluid.Sensors.PartialPressure pCO2Arteries(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.CarbonDioxide_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={-74,-144})));
    Physiolibrary.Fluid.Sensors.PartialPressure pO2Arteries(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.Oxygen_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={-76,-190})));
    Physiolibrary.Fluid.Sensors.PressureMeasure pressureArterial(redeclare
        package Medium = Blood)
      annotation (Placement(transformation(extent={{-124,-228},{-104,-208}})));
    Physiolibrary.Fluid.Sensors.PressureMeasure PressureVeins(redeclare package
        Medium = Blood)
      annotation (Placement(transformation(extent={{-374,-216},{-394,-196}})));
    Physiolibrary.Fluid.Components.Resistor ECMOResistance(redeclare package
        Medium = Blood, Resistance=7999343.2449*(5/5))
      annotation (Placement(transformation(extent={{-326,92},{-306,112}})));
    Physiolibrary.Fluid.Sensors.PressureMeasure pressureOxygenator(redeclare
        package Medium = Blood)
      annotation (Placement(transformation(extent={{-162,136},{-142,156}})));
    Physiolibrary.Fluid.Components.ElasticVessel ECMOBloodTube(
      redeclare package Medium = Blood,
      useSubstances=true,
      volume_start=0.00012,
      useThermalPort=true,
      Compliance(displayUnit="ml/mmHg") = 7.5006157584566e-09,
      ZeroPressureVolume(displayUnit="ml") = 0.00012,
      ExternalPressure(displayUnit="mmHg") = 100658.40249833,
      nPorts=4)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-190,102})));
    Physiolibrary.Fluid.Sources.PressureSource AirPressureSource(redeclare
        package Medium = Air)
      annotation (Placement(transformation(extent={{-294,174},{-274,194}})));
    Physiolibrary.Fluid.Components.ElasticVessel ECMOAirTube(
      redeclare package Medium = Air,
      use_concentration_start=true,
      concentration_start={0.21,40/760,0,1 - 0.21 - 40/760},
      useSubstances=true,
      volume_start(displayUnit="l") = 0.001,
      useThermalPort=false,
      Compliance(displayUnit="ml/mmHg") = 7.5006157584566e-09,
      ZeroPressureVolume(displayUnit="l") = 0.001,
      ExternalPressure(displayUnit="mmHg") = 100791.72488574,
      nPorts=4)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=270,
          origin={-190,184})));

    Physiolibrary.Fluid.Sensors.PressureMeasure pressureECMOAirTube(redeclare
        package Medium = Air)
      annotation (Placement(transformation(extent={{-146,202},{-126,222}})));
    inner Modelica.Fluid.System system(T_ambient=310.15)
      annotation (Placement(transformation(extent={{-524,396},{-504,416}})));
    Physiolibrary.Thermal.Sources.UnlimitedHeat BodyHeat(T=310.15)
      annotation (Placement(transformation(extent={{-230,-350},{-210,-330}})));
    Physiolibrary.Thermal.Components.Conductor conductor(Conductance=69780)
      annotation (Placement(transformation(extent={{-192,-350},{-172,-330}})));
    Physiolibrary.Thermal.Sources.UnlimitedHeat ECMOHeater(T=310.15)
      annotation (Placement(transformation(extent={{-54,98},{-74,118}})));
    Physiolibrary.Thermal.Components.Conductor conductor1(Conductance=69780)
      annotation (Placement(transformation(extent={{-112,98},{-132,118}})));
    Physiolibrary.Fluid.Components.VolumePump heartRight(
      redeclare package Medium = Blood,
      useSolutionFlowInput=true,
      SolutionFlow(displayUnit="l/min"))                       annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-372,-10})));
    Physiolibrary.Fluid.Components.VolumePump heartLeft(
      redeclare package Medium = Blood,
      useSolutionFlowInput=true,
      SolutionFlow(displayUnit="l/min"))                       annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={8,-6})));
    Physiolibrary.Fluid.Components.ElasticVessel LungsArteries(
      redeclare package Medium = Blood,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.00038,
      Compliance(displayUnit="ml/mmHg") = 3.6002955640592e-08,
      ZeroPressureVolume(displayUnit="l") = 0.0003,
      nPorts=4)
      annotation (Placement(transformation(extent={{-382,432},{-362,452}})));
    Physiolibrary.Fluid.Components.ElasticVessel LungsVeins(
      redeclare package Medium = Blood,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.0004,
      Compliance(displayUnit="ml/mmHg") = 7.5006157584566e-08,
      ZeroPressureVolume(displayUnit="l") = 0.0004,
      nPorts=5) annotation (Placement(transformation(extent={{22,430},{2,450}})));
    Physiolibrary.Fluid.Components.Conductor shunt(redeclare package Medium =
          Blood, Conductance(displayUnit="l/(cmH2O.s)") = C_shunt)
               annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-186,392})));
    Physiolibrary.Fluid.Sensors.FlowMeasure flowMeasureCardiacOutput(redeclare
        package Medium = Blood) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={8,-38})));
    Physiolibrary.Fluid.Sources.PressureSource pressureSource(redeclare package
        Medium = Physiolibrary.Media.Air)
      annotation (Placement(transformation(extent={{-376,672},{-356,692}})));
    Physiolibrary.Fluid.Components.VolumePump DeadSpace(
      redeclare package Medium = Physiolibrary.Media.Air,
      useSolutionFlowInput=false,
      SolutionFlow=DV*RR)
      annotation (Placement(transformation(extent={{-204,672},{-184,692}})));
    Physiolibrary.Fluid.Sources.VolumeOutflowSource MinuteVolume(
      useSolutionFlowInput=false,
      SolutionFlow=RR*TV,
      redeclare package Medium = Physiolibrary.Media.Air) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-4,682})));
    Physiolibrary.Fluid.Sensors.PartialPressure pO2Veins(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.Oxygen_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{-338,-174},{-318,-194}})));
    Physiolibrary.Fluid.Sensors.PartialPressure pCO2Veins(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.CarbonDioxide_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={-320,-138})));
    Physiolibrary.Fluid.Sources.PressureSource O2PressureSource(redeclare
        package Medium =
                 Air,
      use_concentration_start=false,
      massFractions_start={1,0,0})
      annotation (Placement(transformation(extent={{-294,212},{-274,232}})));
    Physiolibrary.Fluid.Components.VolumePump O2PumpECMO(redeclare package
        Medium =
          Physiolibrary.Media.Air,
      useSolutionFlowInput=true,
      SolutionFlow(displayUnit="l/min"))
      annotation (Placement(transformation(extent={{-256,212},{-236,232}})));
    Physiolibrary.Fluid.Components.VolumePump AirPumpECMO(redeclare package
        Medium = Physiolibrary.Media.Air,
      useSolutionFlowInput=true,
      SolutionFlow(displayUnit="l/min"))
      annotation (Placement(transformation(extent={{-252,174},{-232,194}})));
    Chemical.Components.Diffusion O2Diffusion(KC=1e-4) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-202,136})));
    Chemical.Components.Diffusion CO2Diffusion(KC=1e-4) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-176,136})));
    Physiolibrary.Types.Constants.HydraulicConductanceConst StarlingSlopeRight(k=
          StarlingRight)
      annotation (Placement(transformation(extent={{-442,-8},{-434,0}})));
    Modelica.Blocks.Math.Product product2 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-406,-10})));
    Physiolibrary.Fluid.Sensors.PressureMeasure pressureLungsVein(redeclare
        package Medium = Blood)
      annotation (Placement(transformation(extent={{26,104},{46,124}})));
    Physiolibrary.Types.Constants.HydraulicConductanceConst StarlingSlopeLeft(k=
          StarlingLeft)
      annotation (Placement(transformation(extent={{52,118},{60,126}})));
    Modelica.Blocks.Math.Product product1 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={102,116})));
    Physiolibrary.Fluid.Components.VolumePump volumePump(
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen,
      useSolutionFlowInput=true,
      SolutionFlow=0)
      annotation (Placement(transformation(extent={{-202,-66},{-222,-46}})));
    Physiolibrary.Fluid.Components.VolumePump volumePump1(
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen,
      useSolutionFlowInput=true,
      SolutionFlow(displayUnit="l/min"))
      annotation (Placement(transformation(extent={{-54,-66},{-34,-46}})));
    Physiolibrary.Fluid.Components.Conductor conductor2(redeclare package
        Medium = Physiolibrary.Media.Air, Conductance=SWEEP/100)
      annotation (Placement(transformation(extent={{-140,174},{-120,194}})));
    Physiolibrary.Fluid.Sensors.pH pH_Arteries(redeclare package Medium =
          Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{-190,-142},{-170,-122}})));
    Physiolibrary.Fluid.Sources.PressureSource Sweep(redeclare package Medium
        = Air, use_concentration_start=false)
      annotation (Placement(transformation(extent={{-26,176},{-46,196}})));
    Physiolibrary.Fluid.Components.ElasticVessel Alveoly(
      redeclare package Medium = Physiolibrary.Media.Air,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.0016,
      Compliance(displayUnit="ml/mmHg") = 6.0004926067653e-07,
      ZeroPressureVolume(displayUnit="l") = 0.0013,
      ExternalPressure(displayUnit="mmHg") = 100791.72488574,
      nPorts=3) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-212,616})));
    Physiolibrary.Fluid.Sensors.FlowMeasure flowMeasureAlveols(redeclare
        package Medium =
                 Physiolibrary.Media.Air)
      annotation (Placement(transformation(extent={{-168,628},{-148,648}})));
    Physiolibrary.Fluid.Components.Conductor conductor3(redeclare package
        Medium =
          Physiolibrary.Media.Air, Conductance(displayUnit="l/(cmH2O.s)")=
        C_ventilation)
                  annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-286,638})));
    Chemical.Components.GasSolubility O2(KC=1e-4)
      annotation (Placement(transformation(extent={{-240,564},{-220,584}})));
    Chemical.Components.GasSolubility CO2(KC=1e-4)
      annotation (Placement(transformation(extent={{-196,568},{-176,588}})));
    Physiolibrary.Fluid.Sensors.PartialPressure pO2Lungs(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.Oxygen_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{-294,562},{-274,582}})));
    Physiolibrary.Fluid.Sensors.PartialPressure pCO2Lungs(
      redeclare package stateOfMatter = Chemical.Interfaces.IdealGas,
      substanceData=Chemical.Substances.CarbonDioxide_gas(),
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={-136,574})));
    Physiolibrary.Fluid.Components.Conductor conductor4(redeclare package
        Medium =
          Blood, Conductance=C_cirkulation*(8/7))
      annotation (Placement(transformation(extent={{-276,460},{-256,480}})));
    Physiolibrary.Fluid.Components.Conductor conductor5(redeclare package
        Medium =
          Blood, Conductance=C_cirkulation*8)
      annotation (Placement(transformation(extent={{-106,464},{-86,484}})));
    Physiolibrary.Fluid.Components.ElasticVessel LungCapilars(
      redeclare package Medium = Physiolibrary.Media.BloodBySiggaardAndersen,
      useSubstances=true,
      volume_start(displayUnit="l") = 0.00015,
      Compliance(displayUnit="ml/mmHg") = 3.0002463033826e-08,
      ZeroPressureVolume(displayUnit="l") = 0.0001,
      nPorts=4) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-198,530})));
    Physiolibrary.Fluid.Sensors.PressureMeasure TlakKapilaryPlice(redeclare
        package Medium = Blood)
      annotation (Placement(transformation(extent={{-112,536},{-92,556}})));
    Physiolibrary.Fluid.Sensors.PressureMeasure pressureAlveols(redeclare
        package Medium =
                 Physiolibrary.Media.Air)
      annotation (Placement(transformation(extent={{-42,608},{-22,628}})));
    Physiolibrary.Fluid.Sensors.pH pH_Veins(redeclare package Medium =
          Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{-218,-138},{-238,-118}})));
    Physiolibrary.Fluid.Sensors.FlowMeasure flowMeasureSweep(redeclare package
        Medium = Physiolibrary.Media.Air) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-88,184})));
    Physiolibrary.Fluid.Components.Conductor conductor6(redeclare package
        Medium =
          Physiolibrary.Media.Air, Conductance(displayUnit="l/(cmH2O.s)")=
        C_ventilation)
                  annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-98,638})));
    Physiolibrary.Fluid.Sensors.pH pH_LungA(redeclare package Medium =
          Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{-420,432},{-400,452}})));
    Physiolibrary.Fluid.Sensors.pH pH_LungV(redeclare package Medium =
          Physiolibrary.Media.BloodBySiggaardAndersen)
      annotation (Placement(transformation(extent={{86,430},{66,450}})));
    Physiolibrary.Fluid.Sensors.FlowMeasure flowMeasureECMO(redeclare package
        Medium = Blood) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-274,102})));
    Components.AirSupplyECMO airSupplyECMO(SWEEP=SWEEP, FiO2=FiO2) annotation (
        Placement(transformation(rotation=0, extent={{-264,282},{-244,302}})));
    Components.FlowSupplyECMO flowSupplyECMO(VAV=VAV, RPM=RPM) annotation (
        Placement(transformation(rotation=0, extent={{-220,-28},{-200,-8}})));
  equation
    connect(resistor1.q_in, Arteries.q_in[1]) annotation (Line(
        points={{-150,-164},{-125.9,-164},{-125.9,-156.549}},
        color={127,0,0},
        thickness=0.5));
    connect(resistor2.q_in, Tissue.q_in[1]) annotation (Line(
        points={{-210,-164},{-210,-248.1},{-192.08,-248.1}},
        color={127,0,0},
        thickness=0.5));
    connect(resistor1.q_out, Tissue.q_in[2]) annotation (Line(
        points={{-170,-164},{-170,-248.1},{-191.04,-248.1}},
        color={127,0,0},
        thickness=0.5));
    connect(PressureCapilarsBody.q_in, Tissue.q_in[3]) annotation (Line(
        points={{-268,-234},{-190,-234},{-190,-248.1}},
        color={127,0,0},
        thickness=0.5));
    connect(O2_left.port_a, Tissue.substances[2]) annotation (Line(points={{-256,-300},
            {-190,-300},{-190,-258}}, color={158,66,200}));
    connect(O2_left.port_a, pO2_tissue.port_a) annotation (Line(points={{-256,-300},
            {-234,-300},{-234,-270},{-256,-270}}, color={158,66,200}));
    connect(pO2_tissue.referenceFluidPort, Tissue.q_in[4]) annotation (Line(
        points={{-266,-260.2},{-266,-248},{-212,-248},{-212,-248.1},{-188.96,-248.1}},
        color={127,0,0},
        thickness=0.5));

    connect(pCO2_tissue.referenceFluidPort, Tissue.q_in[5]) annotation (Line(
        points={{-118,-260.2},{-118,-248.1},{-187.92,-248.1}},
        color={127,0,0},
        thickness=0.5));
    connect(CO2_in.port_b, Tissue.substances[3]) annotation (Line(points={{-130,-300},
            {-190,-300},{-190,-258}}, color={158,66,200}));
    connect(CO2_in.port_b, pCO2_tissue.port_a) annotation (Line(points={{-130,-300},
            {-154,-300},{-154,-270},{-128,-270}}, color={158,66,200}));
    connect(resistor2.q_out, Veins.q_in[1]) annotation (Line(
        points={{-230,-164},{-256.1,-164},{-256.1,-159.725}},
        color={127,0,0},
        thickness=0.5));
    connect(pO2Arteries.port_a, Arteries.substances[2]) annotation (Line(points={{-86,
            -190},{-116,-190},{-116,-159}},
                                         color={158,66,200}));
    connect(pO2Arteries.referenceFluidPort, Arteries.q_in[2]) annotation (Line(
        points={{-76,-199.8},{-125.9,-199.8},{-125.9,-157.366}},
        color={127,0,0},
        thickness=0.5));
    connect(pCO2Arteries.referenceFluidPort, Arteries.q_in[3]) annotation (Line(
        points={{-74,-153.8},{-74,-158.183},{-125.9,-158.183}},
        color={127,0,0},
        thickness=0.5));
    connect(pCO2Arteries.port_a, Arteries.substances[3])
      annotation (Line(points={{-84,-144},{-116,-144},{-116,-159}},
                                                           color={158,66,200}));
    connect(BodyHeat.port, conductor.q_in) annotation (Line(
        points={{-210,-340},{-192,-340}},
        color={191,0,0},
        thickness=0.5));
    connect(conductor.q_out, Tissue.heatPort) annotation (Line(
        points={{-172,-340},{-170,-340},{-170,-258},{-179.8,-258},{-179.8,-254}},
        color={191,0,0},
        thickness=0.5));

    connect(PressureVeins.q_in, Veins.q_in[2]) annotation (Line(
        points={{-380,-212},{-250,-212},{-250,-160.375},{-256.1,-160.375}},
        color={127,0,0},
        thickness=0.5));
    connect(pressureECMOAirTube.q_in, ECMOAirTube.q_in[1]) annotation (Line(
        points={{-140,206},{-188.05,206},{-188.05,183.9}},
        color={127,0,0},
        thickness=0.5));
    connect(ECMOHeater.port, conductor1.q_in) annotation (Line(
        points={{-74,108},{-112,108}},
        color={191,0,0},
        thickness=0.5));
    connect(conductor1.q_out, ECMOBloodTube.heatPort) annotation (Line(
        points={{-132,108},{-179.8,108}},
        color={191,0,0},
        thickness=0.5));
    connect(flowMeasureCardiacOutput.q_out, Arteries.q_in[4]) annotation (Line(
        points={{8,-48},{8,-159},{-125.9,-159}},
        color={127,0,0},
        thickness=0.5));
    connect(heartRight.q_in, Veins.q_in[3]) annotation (Line(
        points={{-372,-20},{-372,-161.025},{-256.1,-161.025}},
        color={127,0,0},
        thickness=0.5));
    connect(heartRight.q_out, LungsArteries.q_in[1]) annotation (Line(
        points={{-372,0},{-372,424},{-372.1,424},{-372.1,443.95}},
        color={127,0,0},
        thickness=0.5));
    connect(shunt.q_out, LungsVeins.q_in[1]) annotation (Line(
        points={{-176,392},{12.1,392},{12.1,442.08}},
        color={127,0,0},
        thickness=0.5));
    connect(heartLeft.q_in, LungsVeins.q_in[2]) annotation (Line(
        points={{8,4},{12.1,441.04}},
        color={127,0,0},
        thickness=0.5));
    connect(heartLeft.q_out, flowMeasureCardiacOutput.q_in) annotation (Line(
        points={{8,-16},{8,-28}},
        color={127,0,0},
        thickness=0.5));
    connect(LungsArteries.q_in[2], shunt.q_in) annotation (Line(
        points={{-372.1,442.65},{-372,442.65},{-372,392},{-196,392}},
        color={127,0,0},
        thickness=0.5));
    connect(pressureSource.y, DeadSpace.q_in) annotation (Line(
        points={{-356,682},{-204,682}},
        color={127,0,0},
        thickness=0.5));
    connect(DeadSpace.q_out, MinuteVolume.q_in) annotation (Line(
        points={{-184,682},{-14,682}},
        color={127,0,0},
        thickness=0.5));

    connect(O2PressureSource.y,O2PumpECMO. q_in) annotation (Line(
        points={{-274,222},{-256,222}},
        color={127,0,0},
        thickness=0.5));
    connect(O2PumpECMO.q_out, ECMOAirTube.q_in[2]) annotation (Line(
        points={{-236,222},{-189.35,222},{-189.35,183.9}},
        color={127,0,0},
        thickness=0.5));
    connect(AirPumpECMO.q_out, ECMOAirTube.q_in[3]) annotation (Line(
        points={{-232,184},{-194,184},{-194,188},{-190.65,188},{-190.65,183.9}},
        color={127,0,0},
        thickness=0.5));

    connect(AirPressureSource.y, AirPumpECMO.q_in) annotation (Line(
        points={{-274,184},{-252,184}},
        color={127,0,0},
        thickness=0.5));
    connect(O2Diffusion.port_b, ECMOAirTube.substances[1]) annotation (Line(
          points={{-202,146},{-202,152},{-190,152},{-190,174}},
                                                              color={158,66,200}));
    connect(CO2Diffusion.port_b, ECMOAirTube.substances[2]) annotation (Line(
          points={{-176,146},{-176,152},{-190,152},{-190,174}},
                                                        color={158,66,200}));
    connect(CO2Diffusion.port_a, ECMOBloodTube.substances[3]) annotation (Line(
          points={{-176,126},{-176,112},{-190,112}},color={158,66,200}));
    connect(O2Diffusion.port_a, ECMOBloodTube.substances[2])
      annotation (Line(points={{-202,126},{-202,114},{-190,114},{-190,112}},
                                                       color={158,66,200}));
    connect(StarlingSlopeRight.y, product2.u1)
      annotation (Line(points={{-433,-4},{-418,-4}}, color={0,0,127}));
    connect(PressureVeins.pressure, product2.u2) annotation (Line(points={{-390,
            -210},{-418,-210},{-418,-16}},                         color={0,0,127}));
    connect(product2.y, heartRight.solutionFlow) annotation (Line(points={{-395,
            -10},{-390,-10},{-390,-8},{-379,-8},{-379,-10}},
                                                      color={0,0,127}));
    connect(pressureLungsVein.pressure, product1.u2)
      annotation (Line(points={{42,110},{90,110}},   color={0,0,127}));
    connect(product1.y, heartLeft.solutionFlow) annotation (Line(points={{113,116},
            {122,116},{122,-6},{15,-6}},  color={0,0,127}));
    connect(pressureLungsVein.q_in, LungsVeins.q_in[3]) annotation (Line(
        points={{32,108},{32,88},{12.1,88},{12.1,440}},
        color={127,0,0},
        thickness=0.5));

    connect(flowSupplyECMO.y1,
                        volumePump.solutionFlow) annotation (Line(points={{-210,
            -28},{-232,-28},{-232,-49},{-212,-49}},   color={0,0,127}));
    connect(pressureArterial.q_in, Arteries.q_in[5]) annotation (Line(
        points={{-118,-224},{-126,-224},{-126,-159.817},{-125.9,-159.817}},
        color={127,0,0},
        thickness=0.5));
    connect(flowSupplyECMO.y,
                        volumePump1.solutionFlow)
      annotation (Line(points={{-200,-28},{-44,-28},{-44,-49}},
                                                     color={0,0,127}));
    connect(pressureOxygenator.q_in, ECMOBloodTube.q_in[1]) annotation (Line(
        points={{-156,140},{-156,102.1},{-191.95,102.1}},
        color={127,0,0},
        thickness=0.5));
    connect(pH_Arteries.referenceFluidPort, Arteries.q_in[6]) annotation (Line(
        points={{-180,-141.8},{-180,-176},{-125.9,-176},{-125.9,-160.634}},
        color={127,0,0},
        thickness=0.5));
    connect(pCO2Veins.referenceFluidPort, Veins.q_in[4]) annotation (Line(
        points={{-320,-128.2},{-272,-128.2},{-272,-161.675},{-256.1,-161.675}},
        color={127,0,0},
        thickness=0.5));
    connect(pO2Veins.referenceFluidPort, Veins.q_in[5]) annotation (Line(
        points={{-328,-174.2},{-320,-174.2},{-320,-170},{-256.1,-170},{-256.1,-162.325}},
        color={127,0,0},
        thickness=0.5));

    connect(pO2Veins.port_a, Veins.substances[2]) annotation (Line(points={{-318,-184},
            {-304,-184},{-304,-182},{-266,-182},{-266,-162}}, color={158,66,200}));
    connect(pCO2Veins.port_a, Veins.substances[3]) annotation (Line(points={{-310,
            -138},{-294,-138},{-294,-144},{-266,-144},{-266,-162}}, color={158,66,
            200}));
    connect(airSupplyECMO.y,
                         O2PumpECMO.solutionFlow) annotation (Line(points={{-252,
            282},{-252,240},{-246,240},{-246,229}},
                                               color={0,0,127}));
    connect(airSupplyECMO.y1,
                        AirPumpECMO.solutionFlow) annotation (Line(points={{-248,
            282},{-228,282},{-228,191},{-242,191}},       color={0,0,127}));
    connect(conductor2.q_in, ECMOAirTube.q_in[4]) annotation (Line(
        points={{-140,184},{-166,184},{-166,183.9},{-191.95,183.9}},
        color={127,0,0},
        thickness=0.5));
    connect(flowMeasureAlveols.q_in, Alveoly.q_in[1]) annotation (Line(
        points={{-168,638},{-210,638},{-210,615.9},{-213.733,615.9}},
        color={127,0,0},
        thickness=0.5));
    connect(Alveoly.substances[1],O2. gas_port) annotation (Line(points={{-212,
            606},{-212,592},{-220,592},{-220,590},{-234,590},{-234,584},{-230,
            584}},                           color={158,66,200}));
    connect(Alveoly.substances[2],CO2. gas_port) annotation (Line(points={{-212,
            606},{-212,588},{-186,588}},   color={158,66,200}));
    connect(TlakKapilaryPlice.q_in, LungCapilars.q_in[1]) annotation (Line(
        points={{-106,540},{-106,520},{-136,520},{-136,496},{-200,496},{-200,
            510},{-196.05,510},{-196.05,530.1}},
        color={127,0,0},
        thickness=0.5));
    connect(O2.liquid_port, LungCapilars.substances[2]) annotation (Line(points=
           {{-230,564},{-230,550},{-198,550},{-198,540}}, color={158,66,200}));
    connect(CO2.liquid_port, LungCapilars.substances[3]) annotation (Line(
          points={{-186,568},{-186,550},{-198,550},{-198,540}}, color={158,66,
            200}));
    connect(pO2Lungs.referenceFluidPort, LungCapilars.q_in[2]) annotation (Line(
        points={{-284,562.2},{-284,496},{-200,496},{-200,510},{-197.35,510},{
            -197.35,530.1}},
        color={127,0,0},
        thickness=0.5));
    connect(pCO2Lungs.referenceFluidPort, LungCapilars.q_in[2]) annotation (
        Line(
        points={{-136,564.2},{-136,494},{-200,494},{-200,510},{-197.35,510},{
            -197.35,530.1}},
        color={127,0,0},
        thickness=0.5));

    connect(O2.liquid_port, pO2Lungs.port_a) annotation (Line(points={{-230,564},
            {-230,550},{-254,550},{-254,572},{-274,572}}, color={158,66,200}));
    connect(CO2.liquid_port, pCO2Lungs.port_a) annotation (Line(points={{-186,
            568},{-186,550},{-160,550},{-160,574},{-146,574}},            color=
           {158,66,200}));
    connect(conductor4.q_out, LungCapilars.q_in[3]) annotation (Line(
        points={{-256,470},{-198,470},{-198,510},{-198.65,510},{-198.65,530.1}},
        color={127,0,0},
        thickness=0.5));

    connect(conductor5.q_in, LungCapilars.q_in[4]) annotation (Line(
        points={{-106,474},{-200,474},{-200,512},{-199.95,512},{-199.95,530.1}},
        color={127,0,0},
        thickness=0.5));

    connect(conductor4.q_in, LungsArteries.q_in[3]) annotation (Line(
        points={{-276,470},{-372,470},{-372,440},{-372.1,440},{-372.1,441.35}},
        color={127,0,0},
        thickness=0.5));
    connect(conductor5.q_out, LungsVeins.q_in[4]) annotation (Line(
        points={{-86,474},{12,474},{12,440},{12.1,440},{12.1,438.96}},
        color={127,0,0},
        thickness=0.5));
    connect(conductor3.q_in, DeadSpace.q_in) annotation (Line(
        points={{-296,638},{-322,638},{-322,682},{-204,682}},
        color={127,0,0},
        thickness=0.5));

    connect(pressureAlveols.q_in, Alveoly.q_in[2]) annotation (Line(
        points={{-36,612},{-212,612},{-212,615.9}},
        color={127,0,0},
        thickness=0.5));
    connect(pH_Arteries.port_a, Arteries.substances[13]) annotation (Line(
          points={{-170,-132},{-116,-132},{-116,-159}},
          color={158,66,200}));
    connect(pH_Veins.referenceFluidPort, Veins.q_in[6]) annotation (Line(
        points={{-228,-137.8},{-228,-146},{-256.1,-146},{-256.1,-162.975}},
        color={127,0,0},
        thickness=0.5));
    connect(pH_Veins.port_a, Veins.substances[13]) annotation (Line(points={{-238,
            -128},{-266,-128},{-266,-162}},                              color=
            {158,66,200}));
    connect(flowMeasureSweep.q_in, conductor2.q_out) annotation (Line(
        points={{-98,184},{-120,184}},
        color={127,0,0},
        thickness=0.5));
    connect(flowMeasureSweep.q_out, Sweep.y) annotation (Line(
        points={{-78,184},{-62,184},{-62,186},{-46,186}},
        color={127,0,0},
        thickness=0.5));
    connect(conductor6.q_in, flowMeasureAlveols.q_out) annotation (Line(
        points={{-108,638},{-148,638}},
        color={127,0,0},
        thickness=0.5));
    connect(conductor6.q_out, MinuteVolume.q_in) annotation (Line(
        points={{-88,638},{-70,638},{-70,682},{-14,682}},
        color={127,0,0},
        thickness=0.5));
    connect(volumePump1.q_out, Arteries.q_in[7]) annotation (Line(
        points={{-34,-56},{-18,-56},{-18,-126},{-125.9,-126},{-125.9,-161.451}},
        color={127,0,0},
        thickness=0.5));
    connect(volumePump.q_out, Veins.q_in[7]) annotation (Line(
        points={{-222,-56},{-256.1,-56},{-256.1,-163.625}},
        color={127,0,0},
        thickness=0.5));

    connect(pH_LungA.referenceFluidPort, LungsArteries.q_in[4]) annotation (Line(
        points={{-410,432.2},{-410,408},{-372,408},{-372,424},{-372.1,424},{-372.1,
            440.05}},
        color={127,0,0},
        thickness=0.5));

    connect(pH_LungV.referenceFluidPort, LungsVeins.q_in[5]) annotation (Line(
        points={{76,430.2},{76,414},{12,414},{12,424},{12.1,424},{12.1,437.92}},
        color={127,0,0},
        thickness=0.5));
    connect(pH_LungA.port_a, LungsArteries.substances[13])
      annotation (Line(points={{-400,442},{-382,442}}, color={158,66,200}));
    connect(pH_LungV.port_a, LungsVeins.substances[13])
      annotation (Line(points={{66,440},{22,440}}, color={158,66,200}));
    connect(ECMOResistance.q_in, Veins.q_in[8]) annotation (Line(
        points={{-326,102},{-344,102},{-344,-164.275},{-256.1,-164.275}},
        color={127,0,0},
        thickness=0.5));
    connect(volumePump.q_in, ECMOBloodTube.q_in[2]) annotation (Line(
        points={{-202,-56},{-168,-56},{-168,102.1},{-190.65,102.1}},
        color={127,0,0},
        thickness=0.5));
    connect(volumePump1.q_in, ECMOBloodTube.q_in[3]) annotation (Line(
        points={{-54,-56},{-168,-56},{-168,102.1},{-189.35,102.1}},
        color={127,0,0},
        thickness=0.5));
    connect(ECMOResistance.q_out, flowMeasureECMO.q_in) annotation (Line(
        points={{-306,102},{-300,102},{-300,102},{-284,102}},
        color={127,0,0},
        thickness=0.5));
    connect(flowMeasureECMO.q_out, ECMOBloodTube.q_in[4]) annotation (Line(
        points={{-264,102},{-226,102},{-226,102.1},{-188.05,102.1}},
        color={127,0,0},
        thickness=0.5));
    connect(StarlingSlopeLeft.y, product1.u1)
      annotation (Line(points={{61,122},{90,122}}, color={0,0,127}));
    connect(conductor3.q_out, Alveoly.q_in[3]) annotation (Line(
        points={{-276,638},{-210.267,638},{-210.267,615.9}},
        color={127,0,0},
        thickness=0.5));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-660,-460},
              {660,740}})), Diagram(coordinateSystem(preserveAspectRatio=false,
            extent={{-660,-460},{660,740}}), graphics={
          Rectangle(
            extent={{-356,378},{-10,-92}},
            lineColor={0,140,72},
            lineThickness=0.5),
          Rectangle(
            extent={{-424,400},{152,-370}},
            lineColor={238,46,47},
            lineThickness=0.5),
          Text(
            extent={{78,388},{136,340}},
            textColor={238,46,47},
            fontSize=10,
            textString="Body"),
          Rectangle(
            extent={{-424,734},{150,410}},
            lineColor={28,108,200},
            lineThickness=0.5),
          Text(
            extent={{6,728},{96,688}},
            textColor={28,108,200},
            fontSize=10,
            textString="Lungs")}));
  end ECMOSim;

  model ECMOSim_RespRegulation
    extends ECMOSim(DeadSpace(useSolutionFlowInput=true), MinuteVolume(
          useSolutionFlowInput=true));
    parameter Real DVfraction=0.4;

    Physiolibrary.Types.Constants.PressureConst pressure(k(displayUnit="kPa") = 4800)
      annotation (Placement(transformation(extent={{342,-142},{350,-134}})));
    Modelica.Blocks.Math.Add add(k1=-1)
      annotation (Placement(transformation(extent={{376,-154},{396,-134}})));
    Modelica.Blocks.Math.Product product5 annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=90,
          origin={512,-116})));
    Modelica.Blocks.Math.Max max1 annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=90,
          origin={506,-34})));
    Modelica.Blocks.Sources.Constant const2(k=0)
      annotation (Placement(transformation(extent={{462,-96},{482,-76}})));
    Physiolibrary.Types.Constants.VolumeConst volume(k(displayUnit="l") = 0.00035)
                 annotation (Placement(transformation(
          extent={{-4,-4},{4,4}},
          rotation=180,
          origin={426,124})));
    Physiolibrary.Types.Constants.FrequencyConst frequency(k=0.01666666666666667*(
          50/(2 - 0.35)))                      annotation (Placement(
          transformation(
          extent={{-4,-4},{4,4}},
          rotation=180,
          origin={496,106})));
    Modelica.Blocks.Math.Division division annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={458,112})));
    Modelica.Blocks.Math.Add TidalVolume annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={390,118})));
    Physiolibrary.Types.Constants.PressureConst CC(k(displayUnit="kPa") = 4300)
      annotation (Placement(transformation(extent={{302,-208},{310,-200}})));
    Modelica.Blocks.Math.Add scitani(k1=-1) annotation (Placement(
          transformation(
          extent={{10,-10},{-10,10}},
          rotation=180,
          origin={358,-196})));
    Physiolibrary.Types.Constants.VolumeFlowRateConst volumeFlowRate1(k(
          displayUnit="l/min") = 0.0019247533333333)
      annotation (Placement(transformation(extent={{454,-218},{462,-210}})));
    Modelica.Blocks.Math.Division Slope annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=180,
          origin={500,-208})));
    Physiolibrary.Types.Constants.PressureConst pressure1(k(displayUnit="kPa") = 700)
      annotation (Placement(transformation(extent={{382,-212},{390,-204}})));
    Modelica.Blocks.Math.Max max2 annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=180,
          origin={424,-202})));
    Modelica.Blocks.Math.Product product6 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={264,184})));
    Modelica.Blocks.Math.Min min1
      annotation (Placement(transformation(extent={{366,128},{346,148}})));
    Physiolibrary.Types.Constants.VolumeConst volume1(k(displayUnit="l") = 0.00231)
                 annotation (Placement(transformation(
          extent={{-4,-4},{4,4}},
          rotation=180,
          origin={402,146})));
    Modelica.Blocks.Math.Division RespRate annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={300,152})));
    Modelica.Blocks.Math.Product product11
                                          annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={322,198})));
    Modelica.Blocks.Sources.Constant DeadVolumeFraction(k=DVfraction)
      annotation (Placement(transformation(extent={{390,194},{370,214}})));
    Modelica.Blocks.Math.Min min2
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=270,
          origin={500,42})));
    Physiolibrary.Types.Constants.VolumeFlowRateConst volumeFlowRate(k(
          displayUnit="l/min") = 0.002)
      annotation (Placement(transformation(extent={{458,-12},{466,-4}})));
  equation
    connect(volume.y,TidalVolume. u2)
      annotation (Line(points={{421,124},{402,124}},
                                                  color={0,0,127}));
    connect(volumeFlowRate1.y,Slope. u1)
      annotation (Line(points={{463,-214},{488,-214}}, color={0,0,127}));
    connect(scitani.y,max2. u1) annotation (Line(points={{369,-196},{412,-196}},
                                    color={0,0,127}));
    connect(pressure1.y,max2. u2) annotation (Line(points={{391,-208},{412,-208}},
                                    color={0,0,127}));
    connect(CC.y,scitani. u1)
      annotation (Line(points={{311,-204},{346,-204},{346,-202}},
                                                       color={0,0,127}));
    connect(max2.y,Slope. u2)
      annotation (Line(points={{435,-202},{488,-202}}, color={0,0,127}));
    connect(pressure.y,add. u1)
      annotation (Line(points={{351,-138},{374,-138}}, color={0,0,127}));
    connect(add.y,product5. u2) annotation (Line(points={{397,-144},{506,-144},{506,
            -128}},      color={0,0,127}));
    connect(Slope.y,product5. u1) annotation (Line(points={{511,-208},{518,-208},{
            518,-128}},  color={0,0,127}));
    connect(product5.y,max1. u1)
      annotation (Line(points={{512,-105},{512,-46}},  color={0,0,127}));
    connect(const2.y,max1. u2) annotation (Line(points={{483,-86},{500,-86},{500,-46}},
                       color={0,0,127}));
    connect(frequency.y,division. u2)
      annotation (Line(points={{491,106},{470,106}},
                                                   color={0,0,127}));
    connect(division.y,TidalVolume. u1)
      annotation (Line(points={{447,112},{402,112}},
                                                   color={0,0,127}));
    connect(pCO2Arteries.partialPressure,add. u2) annotation (Line(points={{-64,-144},
            {374,-144},{374,-150}},       color={0,0,127}));
    connect(pO2Arteries.partialPressure,scitani. u2) annotation (Line(points={{-66,
            -190},{346,-190}},                                      color={0,0,
            127}));
    connect(MinuteVolume.solutionFlow,division. u1) annotation (Line(points={{-4,689},
            {108,689},{108,690},{510,690},{510,118},{470,118}},       color={0,
            0,127}));
    connect(DeadSpace.solutionFlow,product6. y) annotation (Line(points={{-194,689},
            {-194,724},{253,724},{253,184}},      color={0,0,127}));
    connect(RespRate.y,product6. u1) annotation (Line(points={{289,152},{282,152},
            {282,178},{276,178}},      color={0,0,127}));
    connect(min1.u1,volume1. y) annotation (Line(points={{368,144},{397,144},{397,
            146}},     color={0,0,127}));
    connect(min1.u2,TidalVolume. y) annotation (Line(points={{368,132},{374,132},{
            374,122},{379,122},{379,118}},  color={0,0,127}));
    connect(RespRate.u2,min1. y) annotation (Line(points={{312,146},{332,146},{332,
            138},{345,138}},     color={0,0,127}));
    connect(RespRate.u1,division. u1) annotation (Line(points={{312,158},{510,158},
            {510,118},{470,118}},      color={0,0,127}));
    connect(min1.y,product11. u1) annotation (Line(points={{345,138},{340,138},{340,
            186},{334,186},{334,192}}, color={0,0,127}));
    connect(DeadVolumeFraction.y,product11. u2)
      annotation (Line(points={{369,204},{334,204}}, color={0,0,127}));
    connect(product11.y,product6. u2) annotation (Line(points={{311,198},{300,198},
            {300,188},{276,188},{276,190}}, color={0,0,127}));
    connect(volumeFlowRate.y,min2. u2)
      annotation (Line(points={{467,-8},{494,-8},{494,30}}, color={0,0,127}));
    connect(max1.y,min2. u1)
      annotation (Line(points={{506,-23},{506,30}}, color={0,0,127}));
    connect(min2.y,division. u1) annotation (Line(points={{500,53},{500,80},{510,80},
            {510,118},{470,118}},         color={0,0,127}));
    annotation (Diagram(graphics={
          Rectangle(
            extent={{182,698},{548,-372}},
            lineColor={217,67,180},
            lineThickness=0.5),
          Text(
            extent={{230,724},{534,600}},
            textColor={217,67,180},
            textString="Respiratory regulation",
            fontSize=10)}));
  end ECMOSim_RespRegulation;

  package Components
    model AirSupplyECMO
      Modelica.Blocks.Sources.Constant FiO2ECMO(k=FiO2)
        annotation (Placement(transformation(extent={{-172,-34},{-152,-14}})));
      Modelica.Blocks.Sources.Constant FiO2AIR(k=0.21)
        annotation (Placement(transformation(extent={{-172,-68},{-152,-48}})));
      Modelica.Blocks.Sources.Constant FiO2Pure(k=1)
        annotation (Placement(transformation(extent={{-172,2},{-152,22}})));
      Modelica.Blocks.Math.Add add2(k2=-1)
        annotation (Placement(transformation(extent={{-140,-4},{-120,16}})));
      Modelica.Blocks.Math.Add add3(k2=-1)
        annotation (Placement(transformation(extent={{-136,-42},{-116,-62}})));
      Modelica.Blocks.Math.Add add4
        annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
      Modelica.Blocks.Math.Abs abs1
        annotation (Placement(transformation(extent={{-106,-62},{-86,-42}})));
      Modelica.Blocks.Math.Division division1 annotation (Placement(
            transformation(
            extent={{10,10},{-10,-10}},
            rotation=90,
            origin={-18,-20})));
      Modelica.Blocks.Math.Product product9 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=90,
            origin={8,-64})));
      Modelica.Blocks.Math.Product product10 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=90,
            origin={-46,-64})));
      Physiolibrary.Types.Constants.VolumeFlowRateConst volumeFlowRate3(k(
            displayUnit="l/min") = SWEEP)
        annotation (Placement(transformation(extent={{30,-4},{22,4}})));
          parameter Physiolibrary.Types.VolumeFlowRate SWEEP=0 "Air + O2 flow in ECMO[m3/s]";
          parameter Real FiO2=0.8       "Fraction of oxygen in gas";
      Modelica.Blocks.Interfaces.RealOutput y annotation (Placement(
            transformation(rotation=0, extent={{18,-88},{54,-72}})));
      Modelica.Blocks.Interfaces.RealOutput y1 annotation (Placement(
            transformation(rotation=0, extent={{90,-88},{126,-72}})));
    equation
      connect(FiO2ECMO.y,add2. u2) annotation (Line(points={{-151,-24},{-142,
              -24},{-142,0}},
                     color={0,0,127}));
      connect(FiO2Pure.y,add2. u1)
        annotation (Line(points={{-151,12},{-142,12}},   color={0,0,127}));
      connect(FiO2AIR.y,add3. u1)
        annotation (Line(points={{-151,-58},{-138,-58}}, color={0,0,127}));
      connect(add3.u2,FiO2ECMO. y) annotation (Line(points={{-138,-46},{-140,
              -46},{-140,-24},{-151,-24}},
                                color={0,0,127}));
      connect(add3.y,abs1. u)
        annotation (Line(points={{-115,-52},{-108,-52}}, color={0,0,127}));
      connect(add2.y,add4. u1)
        annotation (Line(points={{-119,6},{-62,6}},      color={0,0,127}));
      connect(abs1.y,add4. u2) annotation (Line(points={{-85,-52},{-78,-52},{
              -78,-6},{-62,-6}},color={0,0,127}));
      connect(add4.y,division1. u2) annotation (Line(points={{-39,0},{-24,0},{
              -24,-8}},   color={0,0,127}));
      connect(volumeFlowRate3.y,division1. u1) annotation (Line(points={{21,0},{
              -12,0},{-12,-8}},      color={0,0,127}));
      connect(product10.u1,add4. u2) annotation (Line(points={{-52,-52},{-78,
              -52},{-78,-6},{-62,-6}},color={0,0,127}));
      connect(product10.u2,division1. y) annotation (Line(points={{-40,-52},{
              -18,-52},{-18,-31}},
                           color={0,0,127}));
      connect(product9.u1,division1. y) annotation (Line(points={{2,-52},{-18,
              -52},{-18,-31}},
                           color={0,0,127}));
      connect(add2.y,product9. u2) annotation (Line(points={{-119,6},{-120,6},{
              -120,22},{36,22},{36,-52},{14,-52}},    color={0,0,127}));
      connect(y, product10.y) annotation (Line(points={{36,-80},{36,-78},{-46,
              -78},{-46,-75}}, color={0,0,127}));
      connect(y1, product9.y) annotation (Line(points={{108,-80},{108,-78},{8,
              -78},{8,-75}}, color={0,0,127}));
      annotation (Diagram(coordinateSystem(extent={{-180,-80},{180,80}}),
            graphics={
            Text(
              extent={{-14,72},{176,6}},
              textColor={0,140,72},
              fontSize=10,
              textString="ECMO circuit")}), Icon(coordinateSystem(extent={{-180,
                -80},{180,80}})));
    end AirSupplyECMO;

    model FlowSupplyECMO
      Modelica.Blocks.Math.Product product4
        annotation (Placement(transformation(extent={{-182,-34},{-202,-14}})));
      Modelica.Blocks.Sources.Constant Rotation(k=RPM)
        annotation (Placement(transformation(extent={{-340,56},{-320,76}})));
      Modelica.Blocks.Math.Product product7 annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-284,60})));
      Modelica.Blocks.Sources.Constant ECMOFlowSlope(k=0.0013)
        annotation (Placement(transformation(extent={{-338,16},{-318,36}})));
      Modelica.Blocks.Math.Add add1(k1=-1)
        annotation (Placement(transformation(extent={{-258,64},{-238,44}})));
      Modelica.Blocks.Sources.Constant ECMOFlowIntercept(k=0.4318)
        annotation (Placement(transformation(extent={{-338,-20},{-318,0}})));
      Physiolibrary.Types.Constants.VolumeFlowRateConst volumeFlowRate2(k(
            displayUnit="l/min") = 1.6666666666667e-05)
        annotation (Placement(transformation(extent={{-280,24},{-272,32}})));
      Modelica.Blocks.Math.Product product8 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-208,48})));
      Modelica.Blocks.Sources.Constant const(k=VAV)
        annotation (Placement(transformation(extent={{-86,28},{-66,48}})));
      Modelica.Blocks.Math.Product product3 annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=270,
            origin={-44,-28})));
      Modelica.Blocks.Sources.Constant const1(k=1 - (VAV))
        annotation (Placement(transformation(extent={{-114,-40},{-134,-20}})));
      Modelica.Blocks.Math.Max max3 annotation (Placement(transformation(
            extent={{10,10},{-10,-10}},
            rotation=90,
            origin={-148,26})));
      Physiolibrary.Types.Constants.VolumeFlowRateConst volumeFlowRate4(k(
            displayUnit="l/min") = 0)
        annotation (Placement(transformation(extent={{-112,50},{-120,58}})));
          parameter Real VAV=1   "Distribution of blood to veins and arteries, Values from 0 (100 % Veins) to 1(100 % Arteries";
          parameter Real RPM=0    "Rotation per minute in ECMO pump";
      Modelica.Blocks.Interfaces.RealOutput y annotation (Placement(
            transformation(rotation=0, extent={{-46,-60},{-14,-40}})));
      Modelica.Blocks.Interfaces.RealOutput y1 annotation (Placement(
            transformation(rotation=0, extent={{-206,-60},{-174,-40}})));
    equation
      connect(ECMOFlowSlope.y,product7. u2) annotation (Line(points={{-317,26},{-302,
              26},{-302,52},{-296,52},{-296,54}},
                                                color={0,0,127}));
      connect(ECMOFlowIntercept.y,add1. u1) annotation (Line(points={{-317,-10},{-288,
              -10},{-288,48},{-260,48}},  color={0,0,127}));
      connect(product7.y,add1. u2) annotation (Line(points={{-273,60},{-260,60}},
                                color={0,0,127}));
      connect(volumeFlowRate2.y,product8. u1) annotation (Line(points={{-271,28},{-230,
              28},{-230,42},{-220,42}},
                               color={0,0,127}));
      connect(add1.y,product8. u2) annotation (Line(points={{-237,54},{-237,54},{-220,
              54}},                       color={0,0,127}));
      connect(Rotation.y,product7. u1)
        annotation (Line(points={{-319,66},{-296,66}}, color={0,0,127}));
      connect(product8.y,max3. u2)
        annotation (Line(points={{-197,48},{-154,48},{-154,38}}, color={0,0,127}));
      connect(const1.y,product4. u2)
        annotation (Line(points={{-135,-30},{-180,-30}},
                                                 color={0,0,127}));
      connect(const.y,product3. u1)
        annotation (Line(points={{-65,38},{-38,38},{-38,-16}}, color={0,0,127}));
      connect(volumeFlowRate4.y,max3. u1)
        annotation (Line(points={{-121,54},{-142,54},{-142,38}}, color={0,0,127}));
      connect(max3.y,product4. u1) annotation (Line(points={{-148,15},{-148,-18},{-180,
              -18}}, color={0,0,127}));
      connect(max3.y,product3. u2) annotation (Line(points={{-148,15},{-148,0},{-50,
              0},{-50,-16}}, color={0,0,127}));
      connect(y, product3.y) annotation (Line(points={{-30,-50},{-30,-44},{-44,
              -44},{-44,-39}}, color={0,0,127}));
      connect(y1, product4.y) annotation (Line(points={{-190,-50},{-190,-24},{
              -203,-24}}, color={0,0,127}));
      annotation (Diagram(coordinateSystem(extent={{-350,-50},{-30,150}})),
          Icon(coordinateSystem(extent={{-350,-50},{-30,150}})));
    end FlowSupplyECMO;
  end Components;

  package Experiments
    model EcmoSim_RespReg_EcmoFlow "Experimentally increased the ecmo flow"
      extends DP_ferkl_ECMO.ECMOSim_RespRegulation(RPM=1000);
    end EcmoSim_RespReg_EcmoFlow;
    annotation ();
  end Experiments;
  annotation (uses(
      Modelica(version="4.0.0"),
      Chemical(version="1.4.0"),
      Physiolibrary(version="3.0.0-alpha11")), version="1");
end DP_ferkl_ECMO;
