subroutine mfront_get_libname(libname)
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
    character(len=*), intent(out) :: libname
!
! Retourne le chemin vers la bibliothèque MFront officielle
!       out  libname: chemin
!
! for define
! aslint: disable=C1510
#include "asterf_config.h"
#include "asterfort/utmess.h"
#include "asterfort/lxlgut.h"
!
! aslint: disable=W1303
! for the path name
! person_in_charge: mathieu.courtois@edf.fr
!
    character(len=512) :: dir, nom512
    integer :: nchar
!
    libname = ' '
    call get_environment_variable('ASTER_LIBDIR', dir, nchar)
    if (nchar > len(libname) - 21) then
        call utmess('F', 'RUNTIME_2', sk='ASTER_LIBDIR', si=len(libname) - 21)
    else if (nchar == 0) then
        call utmess('F', 'RUNTIME_1', sk='ASTER_LIBDIR')
    endif
    libname = dir(1:lxlgut(dir))//'/lib'//ASTERBEHAVIOUR//'.so'
!
end
