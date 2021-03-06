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
! because macros must be on a single line
! aslint: disable=C1509
!
#include "asterf.h"
#include "asterf_debug.h"

#ifdef __DEBUG_ALLOCATE__
#   define DEBUG_LOC_ALLOCATE(a, b, c) DEBUG_LOC(a, b, c)
#else
#   define DEBUG_LOC_ALLOCATE(a, b, c) continue
#endif

! To have a syntax similar to the standard ALLOCATE
#define AS_ALLOCATE(arg, size) DEBUG_LOC_ALLOCATE("alloc", __FILE__, __LINE__) ; call as_allocate(arg, size, strdbg=TO_STRING((arg, size)))
!
#include "asterf_types.h"
!
interface
    subroutine as_allocate(size, vl, vi, vi4, vr, &
                           vc, vk8, vk16, vk24, vk32, &
                           vk80, strdbg)
        integer :: size
    aster_logical,           pointer, optional, intent(out) :: vl(:)
    integer,           pointer, optional, intent(out) :: vi(:)
    integer(kind=4),   pointer, optional, intent(out) :: vi4(:)
    real(kind=8),      pointer, optional, intent(out) :: vr(:)
    complex(kind=8),   pointer, optional, intent(out) :: vc(:)
    character(len=8),  pointer, optional, intent(out) :: vk8(:)
    character(len=16), pointer, optional, intent(out) :: vk16(:)
    character(len=24), pointer, optional, intent(out) :: vk24(:)
    character(len=32), pointer, optional, intent(out) :: vk32(:)
    character(len=80), pointer, optional, intent(out) :: vk80(:)
!
        character(len=*) :: strdbg
    end subroutine as_allocate
end interface
