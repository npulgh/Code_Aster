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
    subroutine coedef(imod, fremod, nbm, young, poiss,&
                      rho, icoq, nbno, numno, nunoe0,&
                      nbnoto, coordo, iaxe, kec, geom,&
                      defm, drmax, torco, tcoef)
        integer :: nbnoto
        integer :: nbno
        integer :: nbm
        integer :: imod
        real(kind=8) :: fremod
        real(kind=8) :: young
        real(kind=8) :: poiss
        real(kind=8) :: rho
        integer :: icoq
        integer :: numno(nbno)
        integer :: nunoe0
        real(kind=8) :: coordo(3, nbnoto)
        integer :: iaxe
        integer :: kec
        real(kind=8) :: geom(9)
        real(kind=8) :: defm(2, nbnoto, nbm)
        real(kind=8) :: drmax
        real(kind=8) :: torco(4, nbm)
        real(kind=8) :: tcoef(10, nbm)
    end subroutine coedef
end interface
