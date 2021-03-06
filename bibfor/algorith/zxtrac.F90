subroutine zxtrac(interp, prec, crit, nbinst, ti,&
                  temps, y, neq, xtract, ier)
    implicit none
#include "asterfort/utmess.h"
#include "blas/zcopy.h"
    integer :: nbinst, neq, ier
    real(kind=8) :: prec, ti(*)
    complex(kind=8) :: xtract(*), y(*)
    character(len=*) :: interp, crit
!-----------------------------------------------------------------------
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
!     EXTRACTION DANS UN TABLEAU CONTENANT DES VECTEURS A DES INSTANTS
!     SUCESSIFS DU VECTEUR EVENTUELLEMENT INTERPOLLE A L INSTANT SOUHAIT
!-----------------------------------------------------------------------
! IN  : INTERP  : TYPE D'INTERPOLATION
! IN  : PREC    : PRECISION DU TEST
! IN  : CRIT    : CRITERE 'ABSOLU' OU 'RELATIF'
! IN  : NBINST  : DIMENSION DE LA LISTE DES INSTANTS
! IN  : TI      : LISTE DES INSTANTS
! IN  : TEMPS   : TEMPS A INTERPOLER
! IN  : Y       : TABLEAU DE VECTEURS A DES INSTANTS DONNES
! IN  : NEQ     : DIMENSION DES VECTEURS
! OUT : XTRACT  : VECTEUR INTERPOLE AU TEMPS TEMPS
! OUT : IER     : CODE RETOUR, = 0 : IL Y A EU EXTRACTION
!-----------------------------------------------------------------------
    real(kind=8) :: prec2
!
!-----------------------------------------------------------------------
    integer :: i
    real(kind=8) :: temps
!-----------------------------------------------------------------------
    ier = 0
!
!     --- RECUPERATION DU CHAMP ---
!
    prec2 = prec
    if (crit(1:7) .eq. 'RELATIF') prec2 = prec * ti(1)
    if (abs( temps - ti(1) ) .le. prec2) then
        call zcopy(neq, y(1), 1, xtract, 1)
        goto 9999
    endif
    if (crit(1:7) .eq. 'RELATIF') prec2 = prec * ti(nbinst)
    if (abs( temps - ti(nbinst) ) .le. prec2) then
        call zcopy(neq, y((nbinst-1)*neq+1), 1, xtract, 1)
        goto 9999
    endif
!
    if (temps .lt. ti(1)) then
        ier = ier + 1
        goto 9999
    endif
    if (temps .gt. ti(nbinst)) then
        ier = ier + 1
        goto 9999
    endif
    if (interp(1:3) .eq. 'NON') then
!
!        --- PAS D'INTERPOLATION ---
        do 20 i = 2, nbinst-1
            if (crit(1:7) .eq. 'RELATIF') prec2 = prec * ti(i)
            if (abs( temps - ti(i) ) .le. prec2) then
                call zcopy(neq, y((i-1)*neq+1), 1, xtract, 1)
                goto 9999
            endif
20      continue
        ier = ier + 1
    else
!        ON INTERDIT L'INTERPOLATION POUR LES COMPLEXES
        call utmess('E', 'ALGORITH11_79')
    endif
!
9999  continue
end subroutine
