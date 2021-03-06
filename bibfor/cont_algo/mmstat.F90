subroutine mmstat(mesh  , iter_newt, nume_inst     , ds_measure,&
                  sddisc, disp_curr, disp_cumu_inst, ds_contact)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/cfdisl.h"
#include "asterfort/mmmbca.h"
#include "asterfort/mmmbca_lac.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=8), intent(in) :: mesh
    integer, intent(in) :: iter_newt
    integer, intent(in) :: nume_inst
    type(NL_DS_Measure), intent(inout) :: ds_measure
    character(len=19), intent(in) :: sddisc
    character(len=19), intent(in) :: disp_curr
    character(len=19), intent(in) :: disp_cumu_inst
    type(NL_DS_Contact), intent(inout) :: ds_contact
!
! --------------------------------------------------------------------------------------------------
!
! Contact - Solve
!
! Continue methods - Management of contact loop
!
! --------------------------------------------------------------------------------------------------
!
! In  mesh             : name of mesh
! In  iter_newt        : index of current Newton iteration
! In  nume_inst        : index of current time step
! IO  ds_measure       : datastructure for measure and statistics management
! In  sddisc           : datastructure for time discretization
! In  disp_curr        : current displacements
! In  disp_cumu_inst   : displacement increment from beginning of current time
! IO  ds_contact       : datastructure for contact management
!
! --------------------------------------------------------------------------------------------------
!
    aster_logical :: l_cont_cont, l_cont_lac
!
! --------------------------------------------------------------------------------------------------
!
!
! - Get parameters
!
    l_cont_cont  = cfdisl(ds_contact%sdcont_defi, 'FORMUL_CONTINUE')
    l_cont_lac   = cfdisl(ds_contact%sdcont_defi, 'FORMUL_LAC')
!
    if (l_cont_cont) then
        call mmmbca(mesh  , iter_newt, nume_inst     , ds_measure,&
                    sddisc, disp_curr, disp_cumu_inst, ds_contact)
    elseif (l_cont_lac) then
        call mmmbca_lac(mesh, disp_curr, ds_contact)
    else
        ASSERT(.false.)
    endif
!
end subroutine
