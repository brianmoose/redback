
[GlobalParams]
  time_factor = 1.e-3
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 10
  xmin = 0
  xmax = 1
  ymin = -0.5
  ymax = 0
[]

[Variables]
  [./temp]
  [../]
  [./pore_pressure]
  [../]
[]

[Materials]
  [./redback_nomech]
    type = RedbackMaterial
    block = 0
    temperature = temp
    pore_pres = pore_pressure
    Aphi = 1
    ar = 10
    ar_F = 1
    ar_R = 1
    are_convective_terms_on = true
    delta = 0.0333333333333
    eta1 = 1e3
    fluid_compressibility = 0.002
    fluid_density = 1
    fluid_thermal_expansion = 0.0007
    gr = 1
    gravity = '0 -1.96 0'
    mu = 0
    # output_properties = mixture_density
    # outputs = all
    Peclet_number = 1.0
    phi0 = 0.3
    pressurization_coefficient = 0.166923076923
    ref_lewis_nb = 4.69267773818e-08
    solid_compressibility = 0.001
    solid_density = 2.5
    solid_thermal_expansion = 1e-05
    total_porosity = total_porosity
  [../]
[]

[Functions]
  [./init_gradient_T]
    type = ParsedFunction
    value = 0.0-y*(1.0-0.0)*1000/500
  [../]
  [./init_gradient_P]
    # P_top-rho*g*y
    type = ParsedFunction
    value = 0.02-1.96*y
  [../]
  [./timestep_function]
    type = ParsedFunction
    value = 'min(max(1e-15, dt*max(0.2, 1-0.05*(n_li-50))), (1e-1)*50.0/max(abs(v_max), abs(v_min)))'
    vals = 'num_li num_nli min_fluid_vel_y max_fluid_vel_y dt'
    vars = 'n_li n_nli v_min v_max dt'
  [../]
[]

[ICs]
  [./temp_IC]
    variable = temp
    type = FunctionWithRandomIC
    function = init_gradient_T
    max = 0.1
  [../]
  [./press_IC]
    variable = pore_pressure
    type = FunctionIC
    function = init_gradient_P
  [../]
[]

[BCs]
  [./temperature_top]
    type = DirichletBC
    variable = temp
    boundary = top
    value = 0.0
  [../]
  [./temperature_bottom]
    type = DirichletBC
    variable = temp
    boundary = bottom
    value = 1.0
  [../]
  [./pore_pressure_top]
    type = DirichletBC
    variable = pore_pressure
    boundary = top
    value = 0.02
  [../]
[]

[AuxVariables]
  [./total_porosity]
    family = MONOMIAL
  [../]
  [./Lewis_number]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./fluid_vel_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  active = 'press_td temp_diff press_thermPress temp_td press_diff pres_conv temp_conv'
  [./temp_td]
    type = TimeDerivative
    variable = temp
  [../]
  #[./temp_diff]
  #  type = Diffusion
  #  variable = temp
  #[../]
  [./temp_diff]
    type = RedbackThermalDiffusion
    variable = temp
  [../]
  [./temp_conv]
    type = RedbackThermalConvection
    variable = temp
  [../]
  [./press_td]
    type = TimeDerivative
    variable = pore_pressure
  [../]
  [./press_diff]
    type = RedbackMassDiffusion
    variable = pore_pressure
  [../]
  [./pres_conv]
    type = RedbackMassConvection
    variable = pore_pressure
    temperature = temp
  [../]
  [./press_thermPress]
    type = RedbackThermalPressurization
    variable = pore_pressure
    temperature = temp
  [../]
[]

[AuxKernels]
  [./total_porosity]
    type = RedbackTotalPorosityAux
    variable = total_porosity
    mechanical_porosity = 0
    execute_on = linear
  [../]
  [./Lewis_number]
    type = MaterialRealAux
    variable = Lewis_number
    property = lewis_number
  [../]
  [./fluid_vel_y]
    type = MaterialRealVectorValueAux
    component = 1
    variable = fluid_vel_y
    property = fluid_velocity
  [../]
[]

[Preconditioning]
  # active = ''
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Postprocessors]
#  active = ''
  [./middle_temp]
    type = PointValue
    variable = temp
    point = '0.5 -0.25 0'
  [../]
  [./middle_press]
    type = PointValue
    variable = pore_pressure
    point = '0.5 -0.25 0'
  [../]
  [./middle_porosity]
    type = PointValue
    variable = total_porosity
    point = '0.5 -0.25 0'
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./num_li]
    type = NumLinearIterations
  [../]
  [./num_nli]
    type = NumNonlinearIterations
  [../]
  [./new_timestep]
    type = FunctionValuePostprocessor
    function = timestep_function
  [../]
  [./max_fluid_vel_y]
    type = ElementExtremeValue
    variable = fluid_vel_y
    execute_on = nonlinear
    value_type = max
  [../]
  [./min_fluid_vel_y]
    type = ElementExtremeValue
    variable = fluid_vel_y
    execute_on = nonlinear
    value_type = min
  [../]
[]

[Executioner]
  start_time = 0.0
  end_time = 1e5
  dtmax = 1e5
  dtmin = 1e-15
  type = Transient
  num_steps = 100000
  dt = 0.1
  l_max_its = 200
  nl_max_its = 10
  solve_type = PJFNK
  #petsc_options_iname = '-pc_type -pc_hypre_type -snes_linesearch_type -ksp_gmres_restart -snes_converged_reason'
  #petsc_options_value = 'hypre boomeramg cp 201 1'
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -ksp_gmres_restart '
  petsc_options_value = 'gmres asm lu 201'
  nl_abs_tol = 1e-9 # 1e-10 to begin with
  reset_dt = true
  line_search = basic
  [./TimeStepper]
    type = PostprocessorDT
    dt = 1e-7
    postprocessor = new_timestep
  [../]
[]

[Outputs]
  file_base = convection2D
  output_initial = true
  exodus = true
  [./console]
    type = Console
    perf_log = true
    output_linear = true
  [../]
[]
