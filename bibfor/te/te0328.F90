subroutine te0328(option, nomte)
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
!.......................................................................
    implicit none
!          ELEMENTS ISOPARAMETRIQUES 3D ET 2D
!    FONCTION REALISEE:
!            OPTION : 'VERIF_JACOBIEN'
!     ENTREES  ---> OPTION : OPTION DE CALCUL
!              ---> NOMTE  : NOM DU TYPE ELEMENT
!.......................................................................
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/dfdm2j.h"
#include "asterfort/dfdm3j.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/tecael.h"
#include "asterfort/utmess.h"
!
    character(len=16) :: nomte, option
!
    aster_logical :: posi, nega
    character(len=24) :: valk(2)
    real(kind=8) :: poids
    integer :: igeom, ipoids, ivf, idfde, ndim, npg, nno, jgano, nnos
    integer :: kp, icodr
    integer :: iadzi, iazk24, codret
!
    codret=0
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PCODRET', 'E', icodr)
!
    call elrefe_info(fami='RIGI', ndim=ndim, nno=nno, nnos=nnos, npg=npg,&
                     jpoids=ipoids, jvf=ivf, jdfde=idfde, jgano=jgano)
!
    posi=.false.
    nega=.false.
    do 1 kp = 1, npg
        if (ndim .eq. 3) then
            call dfdm3j(nno, kp, idfde, zr(igeom), poids)
        else if (ndim.eq.2) then
            call dfdm2j(nno, kp, idfde, zr(igeom), poids)
        else
            goto 9999
        endif
        if (poids .lt. 0.d0) nega=.true.
        if (poids .gt. 0.d0) posi=.true.
  1 end do
!
!
    if (posi .and. nega) then
        call tecael(iadzi, iazk24)
        nno=zi(iadzi-1+2)
        valk(1)=zk24(iazk24-1+3)
        valk(2)=zk24(iazk24-1+3+nno+1)
        call utmess('A', 'MAILLAGE1_1', nk=2, valk=valk)
        codret=1
    endif
!
9999 continue
    zi(icodr-1+1)=codret
!
end subroutine
