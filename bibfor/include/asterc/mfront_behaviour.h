!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine mfront_behaviour&
                     (nomlib, nomsub, stress, statev, ddsdde,&
                      stran, dstran, dtime, temp, dtemp,&
                      predef, dpred, ntens, nstatv, props,&
                      nprops, drot, pnewdt, typmod)
        character(len=*) :: nomlib
        character(len=*) :: nomsub
        real(kind=8) :: stress(*)
        real(kind=8) :: statev(*)
        real(kind=8) :: ddsdde(*)
        real(kind=8) :: stran(*)
        real(kind=8) :: dstran(*)
        real(kind=8) :: dtime
        real(kind=8) :: temp
        real(kind=8) :: dtemp
        real(kind=8) :: predef(*)
        real(kind=8) :: dpred(*)
        integer :: ntens
        integer :: nstatv
        real(kind=8) :: props(*)
        integer :: nprops
        real(kind=8) :: drot(*)
        real(kind=8) :: pnewdt
        integer :: typmod
    end subroutine mfront_behaviour
end interface