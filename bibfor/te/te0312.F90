subroutine te0312(option, nomte)
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/jevech.h"
#include "asterfort/rcvalb.h"
#include "asterfort/utmess.h"
!
    character(len=16) :: option, nomte
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
!
!  CALCUL DU CHARGEMENT DU AU SECHAGE ET A L'HYDRATATION
!.......................................................................
!
    integer :: lmater
    character(len=8) :: fami, poum
    real(kind=8) :: bendog(1),kdessi(1)
    integer :: icodre(2), kpg, spt
!.......................................................................
!
    call jevech('PMATERC', 'L', lmater)
    fami='FPG1'
    kpg=1
    spt=1
    poum='+'
!
    if (option.eq.'CHAR_MECA_HYDR_R') then
        call rcvalb(fami, kpg, spt, poum, zi(lmater),&
                    ' ', 'ELAS', 0, ' ', [0.d0],&
                    1, 'B_ENDOGE', bendog, icodre, 0)
!
        if ((icodre(1).eq.0) .and. (bendog(1).ne.0.d0)) then
            call utmess('F', 'ELEMENTS_22', sk=nomte)
        else
!       -- BENDOGE ABSENT => CHARGEMENT NUL
        endif
    else if (option.eq.'CHAR_MECA_SECH_R') then
        call rcvalb(fami, kpg, spt, poum, zi(lmater),&
                    ' ', 'ELAS', 0, ' ', [0.d0],&
                    1, 'K_DESSIC', kdessi, icodre, 0)
!
        if ((icodre(1).eq.0) .and. (kdessi(1).ne.0.d0)) then
            call utmess('F', 'ELEMENTS_23', sk=nomte)
        else
!       -- KDESSI ABSENT => CHARGEMENT NUL
        endif
    else
        ASSERT(.false.)
    endif
!
end subroutine
