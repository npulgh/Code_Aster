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
! aslint: disable=W1504
!
interface
    subroutine nmconv(noma    , modele, mate   , numedd  , sdnume     ,&
                      fonact  , sddyna, ds_conv, ds_print, ds_measure,&
                      sddisc  , sdcrit , sderro  , ds_algopara, ds_algorom,&
                      ds_inout, comref, matass , solveu  , numins     ,&
                      iterat  , eta   , ds_contact, valinc  , solalg     ,&
                      measse  , veasse)
        use NonLin_Datastructure_type
        use Rom_Datastructure_type
        character(len=8) :: noma
        character(len=24) :: modele
        character(len=24) :: mate
        character(len=24) :: numedd
        character(len=19) :: sdnume
        integer :: fonact(*)
        character(len=19) :: sddyna
        type(NL_DS_Conv), intent(inout) :: ds_conv
        type(NL_DS_Print), intent(inout) :: ds_print
        type(NL_DS_Measure), intent(inout) :: ds_measure
        character(len=19) :: sddisc
        character(len=19) :: sdcrit
        character(len=24) :: sderro
        type(NL_DS_InOut), intent(in) :: ds_inout
        type(NL_DS_AlgoPara), intent(in) :: ds_algopara
        character(len=24) :: comref
        character(len=19) :: matass
        character(len=19) :: solveu
        integer :: numins
        integer :: iterat
        real(kind=8) :: eta
        type(NL_DS_Contact), intent(inout) :: ds_contact
        type(ROM_DS_AlgoPara), intent(in) :: ds_algorom
        character(len=19) :: valinc(*)
        character(len=19) :: solalg(*)
        character(len=19) :: measse(*)
        character(len=19) :: veasse(*)
    end subroutine nmconv
end interface
