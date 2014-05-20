/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef MECHHEAT_H
#define MECHHEAT_H

#include "Kernel.h"

class MechHeat;

template<>
InputParameters validParams<MechHeat>();


class MechHeat : public Kernel
{
public:
  MechHeat(const std::string & name, InputParameters parameters);
  virtual ~MechHeat();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  Real _gr;
  Real _ar;
};


#endif /* MECHHEAT_H */
