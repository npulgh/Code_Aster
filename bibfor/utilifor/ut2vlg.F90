subroutine ut2vlg(nn, nc, p, vl, vg)
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
    implicit none
    real(kind=8) :: p(3, 3), vl(*), vg(*)
!     ------------------------------------------------------------------
!     PASSAGE EN 2D D'UN VECTEUR NN*NC DU REPERE LOCAL AU REPERE GLOBAL
!     ------------------------------------------------------------------
!IN   I   NN   NOMBRE DE NOEUDS
!IN   I   NC   NOMBRE DE COMPOSANTES
!IN   R   P    MATRICE DE PASSAGE 3D DE GLOBAL A LOCAL
!IN   R   VL   NN*NC COMPOSANTES DU VECTEUR DANS LOCAL
!OUT  R   VG   NN*NC COMPOSANTES DU VECTEUR DANS GLOBAL
!     ------------------------------------------------------------------
!-----------------------------------------------------------------------
    integer :: i, nc, nn
!-----------------------------------------------------------------------
    if (mod(nc,2) .eq. 0) then
        do 10 i = 1, nn * nc, 2
            vg(i ) = p(1,1)*vl(i) + p(2,1)*vl(i+1)
            vg(i+1) = p(1,2)*vl(i) + p(2,2)*vl(i+1)
10      continue
!
    else if (mod(nc,2) .eq. 1) then
        do 20 i = 1, nn * nc, 3
            vg(i ) = p(1,1)*vl(i) + p(2,1)*vl(i+1)
            vg(i+1) = p(1,2)*vl(i) + p(2,2)*vl(i+1)
            vg(i+2) = vl(i+2)
20      continue
!
    endif
!
end subroutine
