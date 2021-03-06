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
interface
    subroutine nmextr_comp(field     , field_disc, field_type     , meshz    , modelz   ,&
                           cara_elemz, matez     , ds_constitutive, disp_curr, strx_curr,&
                           varc_curr , varc_refe , time           , ligrelz)
        use NonLin_Datastructure_type
        character(len=19), intent(in) :: field
        character(len=24), intent(in) :: field_type
        character(len=4), intent(in) :: field_disc
        character(len=*), intent(in) :: modelz
        character(len=*), intent(in) :: meshz
        character(len=*), intent(in) :: cara_elemz
        character(len=*), intent(in) :: matez
        type(NL_DS_Constitutive), intent(in) :: ds_constitutive
        character(len=*), intent(in) :: disp_curr
        character(len=*), intent(in) :: strx_curr
        character(len=*), intent(in) :: varc_curr
        character(len=*), intent(in) :: varc_refe
        real(kind=8), intent(in) :: time
        character(len=*), optional, intent(in) :: ligrelz
    end subroutine nmextr_comp
end interface
