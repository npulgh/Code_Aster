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
    subroutine nirmtd(ndim, nno1, nno2, nno3, npg,&
                      iw, vff2, vff3, ivf1, idff1,&
                      vu, vg, vp, igeom, mate,&
                      matr)
        integer :: npg
        integer :: nno3
        integer :: nno2
        integer :: nno1
        integer :: ndim
        integer :: iw
        real(kind=8) :: vff2(nno2, npg)
        real(kind=8) :: vff3(nno3, npg)
        integer :: ivf1
        integer :: idff1
        integer :: vu(3, 27)
        integer :: vg(27)
        integer :: vp(27)
        integer :: igeom
        integer :: mate
        real(kind=8) :: matr(*)
    end subroutine nirmtd
end interface
