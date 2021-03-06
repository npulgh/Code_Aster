subroutine dfdm3d(nno, ipg, ipoids, idfde, coor,&
                  jac, dfdx, dfdy, dfdz)
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
#include "jeveux.h"
#include "asterc/r8gaem.h"
#include "asterfort/matini.h"
#include "asterfort/tecael.h"
#include "asterfort/utmess.h"
#include "asterfort/assert.h"
    integer, intent(in) :: nno, ipg, ipoids, idfde
    real(kind=8), intent(in) :: coor(*)
    real(kind=8), intent(out) ::  jac
    real(kind=8), optional, intent(out) :: dfdx(*)
    real(kind=8), optional, intent(out) :: dfdy(*)
    real(kind=8), optional, intent(out) :: dfdz(*)
! ......................................................................
!    - FONCTION REALISEE:  CALCUL DES DERIVEES DES FONCTIONS DE FORME
!               PAR RAPPORT A UN ELEMENT COURANT EN UN POINT DE GAUSS
!               POUR LES ELEMENTS 3D
!
!    - ARGUMENTS:
!        DONNEES:     NNO           -->  NOMBRE DE NOEUDS
!                     POIDS         -->  POIDS DU POINT DE GAUSS
!              DFDRDE,DFRDN,DFRDK   -->  DERIVEES FONCTIONS DE FORME
!                     COOR          -->  COORDONNEES DES NOEUDS
!
!        RESULTATS:   DFDX          <--  DERIVEES DES F. DE F. / X
!                     DFDY          <--  DERIVEES DES F. DE F. / Y
!                     DFDZ          <--  DERIVEES DES F. DE F. / Z
!                     JAC           <--  JACOBIEN AU POINT DE GAUSS
! ......................................................................
!
    integer :: i, j, ii, k, iadzi, iazk24
    real(kind=8) :: poids, g(3, 3)
    real(kind=8) :: de, dn, dk, j11, j12, j13, j21, j22, j23, j31, j32, j33
    character(len=8) :: nomail
!
    poids = zr(ipoids+ipg-1)
!
    call matini(3, 3, 0.d0, g)
!
    do 100 i = 1, nno
        k = 3*nno*(ipg-1)
        ii = 3*(i-1)
        de = zr(idfde-1+k+ii+1)
        dn = zr(idfde-1+k+ii+2)
        dk = zr(idfde-1+k+ii+3)
        do 101 j = 1, 3
            g(1,j) = g(1,j) + coor(ii+j) * de
            g(2,j) = g(2,j) + coor(ii+j) * dn
            g(3,j) = g(3,j) + coor(ii+j) * dk
101      continue
100  end do
!
    j11 = g(2,2) * g(3,3) - g(2,3) * g(3,2)
    j21 = g(3,1) * g(2,3) - g(2,1) * g(3,3)
    j31 = g(2,1) * g(3,2) - g(3,1) * g(2,2)
    j12 = g(1,3) * g(3,2) - g(1,2) * g(3,3)
    j22 = g(1,1) * g(3,3) - g(1,3) * g(3,1)
    j32 = g(1,2) * g(3,1) - g(3,2) * g(1,1)
    j13 = g(1,2) * g(2,3) - g(1,3) * g(2,2)
    j23 = g(2,1) * g(1,3) - g(2,3) * g(1,1)
    j33 = g(1,1) * g(2,2) - g(1,2) * g(2,1)
!
    jac = g(1,1) * j11 + g(1,2) * j21 + g(1,3) * j31
!
    if (abs(jac) .le. 1.d0/r8gaem()) then
        call tecael(iadzi, iazk24)
        nomail= zk24(iazk24-1+3)(1:8)
        call utmess('F', 'ALGORITH2_59', sk=nomail)
    endif

    if (present(dfdx)) then
        ASSERT(present(dfdy))
        ASSERT(present(dfdz))
        do i = 1, nno
            k = 3*nno*(ipg-1)
            ii = 3*(i-1)
            de = zr(idfde-1+k+ii+1)
            dn = zr(idfde-1+k+ii+2)
            dk = zr(idfde-1+k+ii+3)
            dfdx(i) = ( j11*de + j12*dn + j13*dk ) / jac
            dfdy(i) = ( j21*de + j22*dn + j23*dk ) / jac
            dfdz(i) = ( j31*de + j32*dn + j33*dk ) / jac
        enddo
     else
        ASSERT(.not.present(dfdy))
        ASSERT(.not.present(dfdz))
     endif

    jac = abs(jac)*poids

end subroutine
