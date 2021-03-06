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
interface 
    subroutine rgilin3d(xmat, nmat, var0, varf, nvari,&
                        dt, depst, nstrs, sigf, mfr,&
                        errb3d, teta1, teta2, fl3d, ifour,&
                        istep)
#include "asterf_types.h"
        integer :: nstrs
        integer :: nvari
        integer :: nmat
        real(kind=8) :: xmat(nmat)
        real(kind=8) :: var0(nvari)
        real(kind=8) :: varf(nvari)
        real(kind=8) :: dt
        real(kind=8) :: depst(nstrs)
        real(kind=8) :: sigf(nstrs)
        integer :: mfr
        integer :: errb3d
        real(kind=8) :: teta1
        real(kind=8) :: teta2
        aster_logical :: fl3d
        integer :: ifour
        integer :: istep
    end subroutine rgilin3d
end interface 
