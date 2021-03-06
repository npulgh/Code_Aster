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
!
interface
    subroutine nmcerr(sddisc       , iter_glob_maxi, iter_glob_elas, pas_mini_elas, resi_glob_maxi,&
                      resi_glob_rela, inikry       , ds_contact_)
        use NonLin_Datastructure_type
        character(len=19), intent(in) :: sddisc
        integer, intent(in) :: iter_glob_maxi
        integer, intent(in) :: iter_glob_elas
        real(kind=8), intent(in) :: pas_mini_elas 
        real(kind=8), intent(in) :: inikry
        real(kind=8), intent(in) :: resi_glob_maxi
        real(kind=8), intent(in) :: resi_glob_rela
        type(NL_DS_Contact), optional, intent(in) :: ds_contact_
    end subroutine nmcerr
end interface
