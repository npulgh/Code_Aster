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
    subroutine ascorm(monoap, typcmo, nbsup, nsupp, neq,&
                      nbmode, repmo1, repmo2, amort, momec,&
                      id, temps, recmor, recmop, tabs,&
                      nomsy, vecmod, reasup, spectr, corfre,&
                      muapde, tcosup, nintra, nbdis, f1gup,&
                      f2gup, nopara, nordr)
        integer :: nbmode
        integer :: neq
        integer :: nbsup
        aster_logical :: monoap
        character(len=*) :: typcmo
        integer :: nsupp(*)
        real(kind=8) :: repmo1(nbsup, neq, *)
        real(kind=8) :: repmo2(nbsup, neq, *)
        real(kind=8) :: amort(*)
        character(len=*) :: momec
        integer :: id
        real(kind=8) :: temps
        real(kind=8) :: recmor(nbsup, neq, *)
        real(kind=8) :: recmop(nbsup, neq, *)
        real(kind=8) :: tabs(nbsup, *)
        character(len=16) :: nomsy
        real(kind=8) :: vecmod(neq, *)
        real(kind=8) :: reasup(nbsup, nbmode, *)
        real(kind=8) :: spectr(*)
        aster_logical :: corfre
        aster_logical :: muapde
        integer :: tcosup(nbsup, *)
        integer :: nintra
        integer :: nbdis(nbsup)
        real(kind=8) :: f1gup
        real(kind=8) :: f2gup
        character(len=16) :: nopara(*)
        integer :: nordr(*)
    end subroutine ascorm
end interface
