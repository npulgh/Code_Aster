subroutine maxblc(nomob, xmax)
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
    implicit none
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    character(len=*) :: nomob
    real(kind=8) :: xmax
!
!  BUT:
!
!   DETERMINER LE MAXIMUM DES TERMES D'UN BLOC D UNE MATRICE COMPLEXE
!
!-----------------------------------------------------------------------
!
! NOM----- / /:
!
! NOMOB    /I/: NOM K32 DE L'OBJET COMPLEXE
! XMAX     /M/: MAXIMUM REEL
!
!
!
!
!
    integer :: i, nbterm, llblo
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
    call jemarq()
    call jeveuo(nomob(1:32), 'L', llblo)
    call jelira(nomob(1:32), 'LONMAX', nbterm)
!
    do 10 i = 1, nbterm
        xmax=max(xmax,abs(zc(llblo+i-1)))
10  end do
!
!
    call jedema()
end subroutine
