!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
#include "asterf_types.h"
!
interface
    subroutine cjspla(mod, crit, mater, seuili, seuild,&
                      nvi, epsd, deps, sigd, vind,&
                      sigf, vinf, mecani, nivcjs, niter,&
                      ndec, epscon, iret, trac)
        character(len=8) :: mod
        real(kind=8) :: crit(*)
        real(kind=8) :: mater(14, 2)
        real(kind=8) :: seuili
        real(kind=8) :: seuild
        integer :: nvi
        real(kind=8) :: epsd(6)
        real(kind=8) :: deps(6)
        real(kind=8) :: sigd(6)
        real(kind=8) :: vind(*)
        real(kind=8) :: sigf(6)
        real(kind=8) :: vinf(*)
        character(len=6) :: mecani
        character(len=4) :: nivcjs
        integer :: niter
        integer :: ndec
        real(kind=8) :: epscon
        integer :: iret
        aster_logical :: trac
    end subroutine cjspla
end interface
