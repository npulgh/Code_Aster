!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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
!
interface
    subroutine cfapno(noma, newgeo, ds_contact, lctfd,&
                      ndimg, izone, posnoe, numnoe,&
                      coorne, posnom, tau1m, tau2m, iliai)
        use NonLin_Datastructure_type
        character(len=8), intent(in) :: noma
        type(NL_DS_Contact), intent(in) :: ds_contact
        character(len=19), intent(in) :: newgeo
        real(kind=8), intent(in) :: coorne(3)
        real(kind=8), intent(out) :: tau1m(3)
        real(kind=8), intent(out) :: tau2m(3)
        integer, intent(in) :: izone
        integer, intent(in) :: ndimg
        integer, intent(in) :: posnom(1)
        integer, intent(in) :: posnoe
        integer, intent(in) :: numnoe
        integer, intent(in) :: iliai
        aster_logical, intent(in) :: lctfd
    end subroutine cfapno
end interface
