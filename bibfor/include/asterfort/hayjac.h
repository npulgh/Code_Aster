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
interface
    subroutine hayjac(mod, nmat, coefel, coeft, timed,&
                      timef, yf, deps, nr, nvi,&
                      vind, vinf, yd, dy, crit,&
                      drdy, iret)
        integer :: nvi
        integer :: nr
        integer :: nmat
        character(len=8) :: mod
        real(kind=8) :: coefel(nmat)
        real(kind=8) :: coeft(nmat)
        real(kind=8) :: timed
        real(kind=8) :: timef
        real(kind=8) :: yf(nr)
        real(kind=8) :: deps(6)
        real(kind=8) :: vind(nvi)
        real(kind=8) :: vinf(nvi)
        real(kind=8) :: yd(nr)
        real(kind=8) :: dy(nr)
        real(kind=8) :: crit(*)
        real(kind=8) :: drdy(nr, nr)
        integer :: iret
    end subroutine hayjac
end interface
