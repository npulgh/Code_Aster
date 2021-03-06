subroutine mmmbca(mesh  , iter_newt, nume_inst     , ds_measure,&
                  sddisc, disp_curr, disp_cumu_inst, ds_contact)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/r8prem.h"
#include "asterfort/cfdisi.h"
#include "asterfort/cfdisl.h"
#include "asterfort/cfmmvd.h"
#include "asterfort/cfnumm.h"
#include "asterfort/detrsd.h"
#include "asterfort/diinst.h"
#include "asterfort/infdbg.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mcomce.h"
#include "asterfort/mmalgo.h"
#include "asterfort/mmbouc.h"
#include "asterfort/mm_cycl_prop.h"
#include "asterfort/mm_cycl_stat.h"
#include "asterfort/mmeval_prep.h"
#include "asterfort/mmstac.h"
#include "asterfort/mmeven.h"
#include "asterfort/mmextm.h"
#include "asterfort/mmglis.h"
#include "asterfort/mmimp4.h"
#include "asterfort/mminfi.h"
#include "asterfort/mminfl.h"
#include "asterfort/mminfm.h"
#include "asterfort/mmstaf.h"
#include "asterfort/ndynlo.h"
#include "asterfort/mmfield_prep.h"
#include "asterfort/mreacg.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: ayaovi-dzifa.kudawoo at edf.fr
!
    character(len=8), intent(in) :: mesh
    integer, intent(in) :: iter_newt
    integer, intent(in) :: nume_inst
    type(NL_DS_Measure), intent(inout) :: ds_measure
    character(len=19), intent(in) :: sddisc
    character(len=19), intent(in) :: disp_curr
    character(len=19), intent(in) :: disp_cumu_inst
    type(NL_DS_Contact), intent(inout) :: ds_contact
!
! --------------------------------------------------------------------------------------------------
!
! Contact - Solve
!
! Continue method - Management of contact loop
!
! --------------------------------------------------------------------------------------------------
!
! In  mesh             : name of mesh
! In  iter_newt        : index of current Newton iteration
! In  nume_inst        : index of current time step
! IO  ds_measure       : datastructure for measure and statistics management
! In  sddisc           : datastructure for time discretization
! In  disp_curr        : current displacements
! In  disp_cumu_inst   : displacement increment from beginning of current time
! IO  ds_contact       : datastructure for contact management
!
! --------------------------------------------------------------------------------------------------
!
    integer :: ztabf
    integer :: ifm, niv
    integer :: jdecme, elem_slav_indx, elem_slav_nume, elem_mast_nume
    integer :: indi_cont_curr, indi_cont_prev, indi_frot_prev, indi_frot_curr
    integer :: i_zone, i_elem_slav, i_cont_poin, i_poin_elem
    integer :: model_ndim, nb_cont_zone, loop_cont_vali
    integer :: elem_slav_nbno, nb_poin_elem, nb_elem_slav
    integer :: indi_cont_eval, indi_frot_eval
    integer :: indi_cont_init, indi_frot_init
    real(kind=8) :: ksipr1, ksipr2, ksipc1, ksipc2
    real(kind=8) :: norm(3), tau1(3), tau2(3)
    real(kind=8) :: lagr_cont_node(9), lagr_fro1_node(9), lagr_fro2_node(9)
    real(kind=8) :: elem_slav_coor(27)
    real(kind=8) :: lagr_cont_poin, time_curr
    real(kind=8) :: gap,  gap_user
    real(kind=8) :: pres_frot(3), gap_user_frot(3)
    real(kind=8) :: coef_cont, coef_frot, loop_cont_vale
    character(len=8) :: elem_slav_type
    character(len=19) :: cnscon, cnsfr1, cnsfr2
    character(len=19) :: oldgeo, newgeo
    character(len=19) :: chdepd
    aster_logical :: l_glis
    aster_logical :: l_glis_init, l_veri, l_exis_glis, loop_cont_conv, l_loop_cont
    aster_logical :: l_frot_zone, l_pena_frot, l_frot
    integer :: loop_geom_count, loop_fric_count, loop_cont_count
    integer :: type_adap
    character(len=24) :: sdcont_cychis, sdcont_cyccoe, sdcont_cyceta
    real(kind=8), pointer :: v_sdcont_cychis(:) => null()
    real(kind=8), pointer :: v_sdcont_cyccoe(:) => null()
    integer, pointer :: v_sdcont_cyceta(:) => null()
    character(len=24) :: sdcont_tabfin, sdcont_jsupco, sdcont_apjeu
    real(kind=8), pointer :: v_sdcont_tabfin(:) => null()
    real(kind=8), pointer :: v_sdcont_jsupco(:) => null()
    real(kind=8), pointer :: v_sdcont_apjeu(:) => null()
    aster_logical :: l_coef_adap
!
! --------------------------------------------------------------------------------------------------
!
    call jemarq()
    call infdbg('CONTACT', ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<CONTACT> ... ACTIVATION/DESACTIVATION'
    endif
!
! - Initializations
!
    loop_cont_conv = .true.
    loop_cont_vali = 0
!
! - Parameters
!
    
    l_exis_glis  = cfdisl(ds_contact%sdcont_defi,'EXIS_GLISSIERE')
    l_loop_cont  = cfdisl(ds_contact%sdcont_defi,'CONT_BOUCLE')
    type_adap    = cfdisi(ds_contact%sdcont_defi,'TYPE_ADAPT')
    model_ndim   = cfdisi(ds_contact%sdcont_defi,'NDIM' )
    nb_cont_zone = cfdisi(ds_contact%sdcont_defi,'NZOCO')
    l_frot       = cfdisl(ds_contact%sdcont_defi,'FROTTEMENT')
!
! - Acces to contact objects
!
    ztabf = cfmmvd('ZTABF')
    sdcont_tabfin = ds_contact%sdcont_solv(1:14)//'.TABFIN'
    sdcont_jsupco = ds_contact%sdcont_solv(1:14)//'.JSUPCO'
    sdcont_apjeu  = ds_contact%sdcont_solv(1:14)//'.APJEU'
    call jeveuo(sdcont_tabfin, 'E', vr = v_sdcont_tabfin)
    call jeveuo(sdcont_jsupco, 'E', vr = v_sdcont_jsupco)
    call jeveuo(sdcont_apjeu , 'E', vr = v_sdcont_apjeu)
!
! - Acces to cycling objects
!
    sdcont_cyceta = ds_contact%sdcont_solv(1:14)//'.CYCETA'
    sdcont_cychis = ds_contact%sdcont_solv(1:14)//'.CYCHIS'
    sdcont_cyccoe = ds_contact%sdcont_solv(1:14)//'.CYCCOE'
    call jeveuo(sdcont_cyceta, 'L', vi = v_sdcont_cyceta)
    call jeveuo(sdcont_cychis, 'E', vr = v_sdcont_cychis)
    call jeveuo(sdcont_cyccoe, 'E', vr = v_sdcont_cyccoe)
!
!
! - Get current time
!
    time_curr = diinst(sddisc, nume_inst)
!
! - Geometric update
!
    oldgeo = mesh//'.COORDO'
    newgeo = ds_contact%sdcont_solv(1:14)//'.NEWG'
    call mreacg(mesh, ds_contact, field_update_ = disp_curr)
!
! - Prepare displacement field to get contact Lagrangien multiplier
!
    cnscon = '&&MMMBCA.CNSCON'
    call mmfield_prep(disp_curr, cnscon,&
                      l_sort_ = .true._1, nb_cmp_ = 1, list_cmp_ = ['LAGS_C  '])
!
! - Prepare displacement field to get friction Lagrangien multiplier
!
    chdepd = '&&MMMBCA.CHDEPD'
    cnsfr1 = '&&MMMBCA.CNSFR1'
    cnsfr2 = '&&MMMBCA.CNSFR2'
    if (l_frot) then
        call mmfield_prep(disp_cumu_inst, cnsfr1,&
                          l_sort_ = .true._1, nb_cmp_ = 1, list_cmp_ = ['LAGS_F1 '])
        if (model_ndim .eq. 3) then
            call mmfield_prep(disp_cumu_inst, cnsfr2,&
                              l_sort_ = .true._1, nb_cmp_ = 1, list_cmp_ = ['LAGS_F2 '])
        endif
        call mmfield_prep(oldgeo, chdepd,&
                          l_update_ = .true._1, field_update_ = disp_cumu_inst)
    endif
!
! - Loop on contact zones
!
    i_cont_poin = 1
    do i_zone = 1, nb_cont_zone
!
! ----- Parameters of zone
!
        l_glis       = mminfl(ds_contact%sdcont_defi,'GLISSIERE_ZONE' , i_zone)
        l_veri       = mminfl(ds_contact%sdcont_defi,'VERIF'          , i_zone)
        nb_elem_slav = mminfi(ds_contact%sdcont_defi,'NBMAE'          , i_zone)
        jdecme       = mminfi(ds_contact%sdcont_defi,'JDECME'         , i_zone)
        l_frot_zone  = mminfl(ds_contact%sdcont_defi,'FROTTEMENT_ZONE', i_zone)
        l_pena_frot  = mminfl(ds_contact%sdcont_defi,'ALGO_FROT_PENA' , i_zone)
!
! ----- No computation: no contact point
!
        if (l_veri) then
            goto 25
        endif
!
! ----- Loop on slave elements
!
        do i_elem_slav = 1, nb_elem_slav
!
! --------- Slave element index in contact datastructure
!
            elem_slav_indx = jdecme + i_elem_slav
!
! --------- Informations about slave element
!
            call cfnumm(ds_contact%sdcont_defi, elem_slav_indx, elem_slav_nume)
!
! --------- Number of integration points on element
!
            call mminfm(elem_slav_indx, ds_contact%sdcont_defi, 'NPTM', nb_poin_elem)
!
! --------- Get coordinates of slave element
!
            call mcomce(mesh          , newgeo, elem_slav_nume, elem_slav_coor, elem_slav_type,&
                        elem_slav_nbno)
!
! --------- Get value of contact lagrangian multiplier at slave nodes
!
            call mmextm(ds_contact%sdcont_defi, cnscon, elem_slav_indx, lagr_cont_node)
!
! --------- Get value of friction lagrangian multipliers at slave nodes
!
            if (l_frot_zone) then
                call mmextm(ds_contact%sdcont_defi, cnsfr1, elem_slav_indx, lagr_fro1_node)
                if (model_ndim .eq. 3) then
                    call mmextm(ds_contact%sdcont_defi, cnsfr2, elem_slav_indx, lagr_fro2_node)
                endif
            endif       
!
! --------- Loop on integration points
!
            do i_poin_elem = 1, nb_poin_elem
!
! ------------- Current master element
!
                elem_mast_nume = nint(v_sdcont_tabfin(ztabf*(i_cont_poin-1)+3))
!
! ------------- Get coordinates of the contact point 
!
                ksipc1 = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+4)
                ksipc2 = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+5)
!
! ------------- Get coordinates of the projection of contact point 
!
                ksipr1 = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+6)
                ksipr2 = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+7)
!
! ------------- Get local basis
!
                tau1(1) = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+8)
                tau1(2) = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+9)
                tau1(3) = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+10)
                tau2(1) = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+11)
                tau2(2) = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+12)
                tau2(3) = v_sdcont_tabfin(ztabf*(i_cont_poin-1)+13)
!
! ------------- Store current local basis :
!               needed for previous cycling matrices and vectors computrations
!
                v_sdcont_cychis(60*(i_cont_poin-1)+13) = tau1(1) 
                v_sdcont_cychis(60*(i_cont_poin-1)+14) = tau1(2) 
                v_sdcont_cychis(60*(i_cont_poin-1)+15) = tau1(3) 
                v_sdcont_cychis(60*(i_cont_poin-1)+16) = tau2(1) 
                v_sdcont_cychis(60*(i_cont_poin-1)+17) = tau2(2) 
                v_sdcont_cychis(60*(i_cont_poin-1)+18) = tau2(3) 
                v_sdcont_cychis(60*(i_cont_poin-1)+19) = ksipc1 
                v_sdcont_cychis(60*(i_cont_poin-1)+20) = ksipc2 
                v_sdcont_cychis(60*(i_cont_poin-1)+22) = ksipr1
                v_sdcont_cychis(60*(i_cont_poin-1)+23) = ksipr2 
                v_sdcont_cychis(60*(i_cont_poin-1)+24) = elem_mast_nume

!
! ------------- Compute gap and contact pressure
!
                call mmeval_prep(mesh   , time_curr  , model_ndim     , ds_contact,&
                                  i_zone         ,&
                                 ksipc1 , ksipc2     , ksipr1         , ksipr2    ,&
                                 tau1   , tau2       ,&
                                 elem_slav_indx,  elem_slav_nbno,&
                                 elem_slav_type, elem_slav_coor,&
                                 elem_mast_nume,&
                                 lagr_cont_node,&
                                 norm   , &
                                 gap    , gap_user,  lagr_cont_poin)
!
! ------------- Previous status and coefficients
!
                indi_cont_init = nint(v_sdcont_tabfin(ztabf*(i_cont_poin-1)+23))
                if (l_frot_zone) then
                    indi_frot_init = nint(v_sdcont_tabfin(ztabf*(i_cont_poin-1)+24))
                endif
                coef_cont = v_sdcont_cychis(60*(i_cont_poin-1)+2)
                coef_frot = v_sdcont_cychis(60*(i_cont_poin-1)+6)
!
! ------------- Initial bilateral contact ?
!
                l_glis_init = nint(v_sdcont_tabfin(ztabf*(i_cont_poin-1)+18)).eq.1
!
! ------------- Total gap
!
                gap = gap+gap_user
!
! ------------- Save gaps
!
                v_sdcont_jsupco(i_cont_poin) = gap_user
                v_sdcont_apjeu(i_cont_poin)  = gap
!
! ------------- Excluded nodes => no contact !
!
                if (nint(v_sdcont_tabfin(ztabf*(i_cont_poin-1)+19)) .eq. 1) then
                    indi_cont_curr = 0
                    goto 19
                endif
!
! ------------- Evaluate contact status
!
                call mmstac(gap, lagr_cont_poin, coef_cont, indi_cont_eval)
!
! ------------- Evaluate friction status
!
                if (l_frot_zone) then
                    call mmstaf(mesh, model_ndim, chdepd, coef_frot, l_pena_frot,&
                          elem_slav_nume, elem_slav_type, elem_slav_nbno, elem_mast_nume, ksipc1,&
                                ksipc2, ksipr1, ksipr2, lagr_fro1_node, lagr_fro2_node,&
                                tau1, tau2, norm, pres_frot, gap_user_frot,&
                                indi_frot_eval)
                endif
!
! ------------- Status treatment
!
                call mmalgo(ds_contact, l_loop_cont, l_frot_zone, &
                            l_glis_init, type_adap, i_zone, i_cont_poin, &
                            indi_cont_eval, indi_frot_eval, gap,  lagr_cont_poin,&
                       gap_user_frot, pres_frot, v_sdcont_cychis, v_sdcont_cyccoe, v_sdcont_cyceta,&
                        indi_cont_curr,indi_frot_curr, loop_cont_vali, loop_cont_conv)
!
 19             continue
!
! ------------- Save status
!
                v_sdcont_tabfin(ztabf*(i_cont_poin-1)+23) = indi_cont_curr
                if (l_frot_zone) then
                    v_sdcont_tabfin(ztabf*(i_cont_poin-1)+24) = indi_frot_curr
                endif
!
! ------------- Print status
!
                if (niv .ge. 2) then
                    call mmimp4(ifm, mesh, elem_slav_nume, i_poin_elem, indi_cont_prev,&
                                indi_cont_curr, indi_frot_prev, indi_frot_curr, l_frot, &
                                l_glis, gap,  lagr_cont_poin)
                endif
!
! ------------- Next contact point
!
                i_cont_poin = i_cont_poin + 1
            end do
        end do
 25     continue
    end do
!
! - Bilateral contact management
!
    if (loop_cont_conv .and. l_exis_glis) then
        call mmglis(ds_contact)
    endif
!
! - Statistics for cycling
!
    call mm_cycl_stat(ds_measure, ds_contact)
!
! - Propagation of coefficient
!
    l_coef_adap = ((type_adap .eq. 1) .or. (type_adap .eq. 2)  .or.  &
                  (type_adap .eq. 5) .or. (type_adap .eq. 6) )
    if (l_coef_adap) then
        call mm_cycl_prop(ds_contact)
    endif
!
! - Event management for impact
!
    call mmbouc(ds_contact, 'Geom', 'Read_Counter', loop_geom_count)
    call mmbouc(ds_contact, 'Fric', 'Read_Counter', loop_fric_count)
    call mmbouc(ds_contact, 'Cont', 'Read_Counter', loop_cont_count)
    if ((iter_newt.eq.0) .and.&
        (loop_geom_count.eq.1) .and. (loop_fric_count.eq.1) .and. (loop_cont_count.eq.1)) then
        call mmeven('INI', ds_contact)
    else
        call mmeven('FIN', ds_contact)
    endif
!
! - Set loop values
!
    if (loop_cont_conv) then
        call mmbouc(ds_contact, 'Cont', 'Set_Convergence')
    else
        call mmbouc(ds_contact, 'Cont', 'Set_Divergence')
    endif
    loop_cont_vale = real(loop_cont_vali, kind=8)
    call mmbouc(ds_contact, 'Cont', 'Set_Vale' , loop_vale_ = loop_cont_vale)
!
! - Cleaning
!
    call jedetr(newgeo)
    call jedetr(chdepd)
    call detrsd('CHAM_NO_S', cnscon)
    call detrsd('CHAM_NO_S', cnsfr1)
    call detrsd('CHAM_NO_S', cnsfr2)
!
    call jedema()
end subroutine
