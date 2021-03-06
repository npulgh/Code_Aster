subroutine ef0039(nomte)
! ----------------------------------------------------------------------
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
#include "asterfort/jevech.h"
#include "asterfort/tecach.h"
    character(len=16) :: nomte
! ----------------------------------------------------------------------
!     CALCUL DE EFGE_ELNO
!     ------------------------------------------------------------------
    integer :: itab(2), ieffo, n1, i, iret, icontg
!     ------------------------------------------------------------------
!
    call tecach('OOO', 'PEFFORR', 'E', iret, nval=2,&
                itab=itab)
    ieffo=itab(1)
    n1=itab(2)
!
    call jevech('PCONTRR', 'L', icontg)
!
    do 70 i = 1, n1
        zr(ieffo-1+i)=zr(icontg-1+i)
70  end do
!
end subroutine
