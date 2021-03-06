subroutine montee(nout, lchout, lpaout, fin)

use calcul_module, only : ca_calvoi_, ca_igr_, ca_nbgr_, ca_ligrel_

implicit none
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.

! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.

! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: jacques.pellet at edf.fr

#include "asterfort/monte1.h"
#include "asterfort/typele.h"

    integer :: nout
    character(len=*) :: lchout(*), fin
    character(len=8) :: lpaout(*)
!-----------------------------------------------------------------------
! Entrees:
!     fin    : ' ' / 'FIN' : necessaire a cause de calvoi=1
!
! Sorties:
!     met a jour les champs globaux de sortie de l option ca_nuop_
!-----------------------------------------------------------------------
    integer :: igr2, te2
!-----------------------------------------------------------------------

    if (ca_calvoi_ .eq. 0) then
        if (fin .eq. ' ') then
            igr2=ca_igr_
            te2=typele(ca_ligrel_,igr2,1)
            call monte1(te2, nout, lchout, lpaout,&
                        igr2)
        endif
    else
!       -- on recopie tout a la fin :
        if (fin .eq. 'FIN') then
            do 1, igr2=1,ca_nbgr_
            te2=typele(ca_ligrel_,igr2,1)
            call monte1(te2, nout, lchout, lpaout,&
                        igr2)
 1          continue
        endif
    endif


end subroutine
