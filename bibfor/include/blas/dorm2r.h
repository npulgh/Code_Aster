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
#include "asterf_types.h"

interface
    subroutine dorm2r(side, trans, m, n, k,&
                      a, lda, tau, c, ldc,&
                      work, info)
        integer, intent(in) :: ldc
        integer, intent(in) :: lda
        character(len=1) ,intent(in) :: side
        character(len=1) ,intent(in) :: trans
        integer, intent(in) :: m
        integer, intent(in) :: n
        integer, intent(in) :: k
        real(kind=8) ,intent(in) :: a(lda, *)
        real(kind=8) ,intent(in) :: tau(*)
        real(kind=8) ,intent(inout) :: c(ldc, *)
        real(kind=8) ,intent(out) :: work(*)
        blas_int, intent(out) :: info
    end subroutine dorm2r
end interface
