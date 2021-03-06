subroutine abscvl(ndim, tabar, xg, s)
    implicit none
!
#include "jeveux.h"
#include "asterfort/abscvf.h"
#include "asterfort/assert.h"
#include "asterfort/reereg.h"
#include "asterfort/utmess.h"
    integer :: ndim
    real(kind=8) :: xg(ndim), s, tabar(*)
!
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!                      TROUVER L'ABSCISSE CURVILIGNE D'UN POINT
!                      SUR UNE ARETE QUADRATIQUE A PARTIR DE SES
!                      COORDONNEES DANS L'ELEMENT REEL
!
!     ENTREE
!       NDIM     : DIMENSION TOPOLOGIQUE DU MAILLAGE
!       TABAR    : COORDONNEES DES 3 NOEUDS QUI DEFINISSENT L'ARETE
!       XG       : COORDONNEES DU POINT DANS L'ELEMENT REEL
!
!     SORTIE
!       S        : ABSCISSE CURVILIGNE DU POINT P PAR RAPPORT AU
!                  PREMIER POINT STOCKE DANS COORSG
!     ----------------------------------------------------------------
!
    real(kind=8) :: xgg, a, b, ksider
    real(kind=8) :: tabelt(3), xe(1)
    integer :: iret, k
    character(len=8) :: elp
!
!......................................................................
!
!     TABAR : XE2=-1  /  XE1= 1  /  XE3= 0
!     XE2 ETANT LE POINT D'ORIGINE
!
!      RECHERCHE DE LA MONOTONIE SUR CHAQUE AXE

!   recherche d'un axe sur lequel projete le SE3
    xgg=0.d0

    do 10 k=1, ndim
      a = tabar(k)+tabar(ndim+k)-2*tabar(2*ndim+k)
      b = tabar(ndim+k)-tabar(k)
!
      if (abs(a) .le. 1.d-6) then
        if (abs(b) .gt. 1.d-6) then
!         JE BALANCE SUR K
          tabelt(1)=tabar(k)
          tabelt(2)=tabar(ndim+k)
          tabelt(3)=tabar(2*ndim+k)
          xgg =xg(k)
!         on a trouve un axe sur lequel projete le SE3
          exit
        else if (abs(b).le.1.d-6) then
          if (k .lt. ndim) then
!           on teste l'axe suivant
            goto 10
          else if (k.eq.ndim) then
!           LES 3 POINTS SONT CONFONDUS!
            call utmess('F', 'XFEM_66')
          endif
        endif
      else if (abs(a).gt.1.d-6) then
        ksider = -b/a
        if (ksider .gt. -1.d0 .and. ksider .lt. 1.d0) then
          if (k .lt. ndim) then
!           on teste l'axe suivant
            cycle
          else if (k.eq.ndim) then
!           L'ARETE EST TROP ARRONDIE :
!           IL Y A 2 SOLUTIONS SUIVANT CHAQUE AXE
            call utmess('F', 'XFEM_66')
          endif
        else if (ksider.gt.1.d0 .or. ksider.lt.-1.d0) then
          tabelt(1)=tabar(k)
          tabelt(2)=tabar(ndim+k)
          tabelt(3)=tabar(2*ndim+k)
          xgg =xg(k)
!         on a trouve un axe sur lequel projete le SE3
          exit
        endif
      endif
!
10  end do
!
!   ALIAS DE L'ARETE (QUADRATIQUE)
    elp='SE3'
!
!     CALCUL COORDONNEES DE REF (ETA) DE XGG SUR L'ARETE
    call reereg('S', elp, 3, tabelt, [xgg],&
                1, xe, iret)
    ASSERT(xe(1).ge.-1 .and. xe(1).le.1)
!
!     CALCUL ABSCISSE CURVILIGNE (S) DE XGG
!     ---L'ORIGINE EST LE 1ER PT DE COORSG---
    call abscvf(ndim, tabar, xe(1), s)
!
end subroutine
