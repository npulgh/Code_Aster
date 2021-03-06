subroutine nxpred(model     , mate     , cara_elem, list_load, nume_dof ,&
                  solver    , lostat   , tpsthe   , time     , matass   ,&
                  lonch     , maprec   , varc_curr, temp_prev, temp_iter,&
                  cn2mbr    , hydr_prev, hydr_curr, dry_prev , dry_curr ,&
                  compor    , cndirp   , cnchci   , vec2nd   , vec2ni   ,&
                  ds_algorom)
!
use ROM_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/asasve.h"
#include "asterfort/ascova.h"
#include "asterfort/copisd.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/nxreso.h"
#include "asterfort/romAlgoNLSystemSolve.h"
#include "asterfort/resoud.h"
#include "asterfort/verstp.h"
#include "asterfort/vethbt.h"
#include "asterfort/vethbu.h"
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
! person_in_charge: mickael.abbas at edf.fr
! aslint: disable=W1504
!
    character(len=24), intent(in) :: model
    character(len=24), intent(in) :: mate
    character(len=24), intent(in) :: cara_elem
    character(len=19), intent(in) :: list_load
    character(len=24), intent(in) :: nume_dof
    character(len=19), intent(in) :: solver
    real(kind=8) :: tpsthe(6)
    character(len=24), intent(in) :: time
    character(len=19), intent(in) :: varc_curr
    integer :: lonch
    character(len=19) :: maprec
    character(len=24) :: matass, cndirp, cnchci, cnresi
    character(len=24) :: temp_iter, temp_prev, vec2nd, vec2ni
    character(len=24) :: hydr_prev, hydr_curr, compor, dry_prev, dry_curr
    aster_logical :: lostat
    character(len=24), intent(in) :: cn2mbr
    type(ROM_DS_AlgoPara), intent(in) :: ds_algorom
!
! --------------------------------------------------------------------------------------------------
!
! COMMANDE THER_NON_LINE : PHASE DE PREDICTION
!
! --------------------------------------------------------------------------------------------------
!
!     VAR temp_iter : ITERE PRECEDENT DU CHAMP DE TEMPERATURE
!
! In  cn2mbr : name of vector for second member
!
! --------------------------------------------------------------------------------------------------
!
    integer :: k
    real(kind=8) :: rbid
    real(kind=8) :: time_curr
    character(len=1) :: typres
    character(len=19) :: chsol
    character(len=24) :: bidon, veresi, varesi, vabtla, vebtla
    character(len=24) :: vebuem, vabuem, cnvabt, cnvabu
    character(len=24) :: lload_name, lload_info
    real(kind=8), pointer :: v_vec2ni(:) => null()
    real(kind=8), pointer :: v_vec2nd(:) => null()
    real(kind=8), pointer :: v_cn2mbr(:) => null()
    real(kind=8), pointer :: v_cnvabt(:) => null()
    real(kind=8), pointer :: v_cnvabu(:) => null()
    real(kind=8), pointer :: v_cndirp(:) => null()
    real(kind=8), pointer :: v_cnresi(:) => null()
!
! --------------------------------------------------------------------------------------------------
!
    call jemarq()
    varesi = '&&VARESI'
    cnvabt = ' '
    cnvabu = ' '
    typres = 'R'
    chsol  = '&&NXPRED.SOLUTION'
    bidon  = '&&FOMULT.BIDON'
    veresi = '&&VERESI           .RELR'
    vebtla = '&&VETBTL           .RELR'
    vabtla = ' '
    vebuem = '&&VEBUEM           .RELR'
    vabuem = ' '
    cnresi = ' '
    time_curr = tpsthe(1)
    lload_name = list_load(1:19)//'.LCHA'
    lload_info = list_load(1:19)//'.INFC'
!
! --- RECUPERATION D'ADRESSES
!
    call jeveuo(vec2nd(1:19)//'.VALE', 'L', vr = v_vec2nd)
    call jeveuo(cn2mbr(1:19)//'.VALE', 'E', vr = v_cn2mbr)
    call jeveuo(vec2ni(1:19)//'.VALE', 'L', vr = v_vec2ni)
    call jeveuo(cndirp(1:19)//'.VALE', 'L', vr = v_cndirp)
!
    if (lostat) then
!
!=======================================================================
!  INITIALISATION POUR LE PREMIER PAS DE CALCUL
!=======================================================================
!
! ----- Neumann loads elementary vectors (residuals)
!
        call verstp(model    , lload_name, lload_info, mate     , time_curr,&
                    time     , compor    , temp_prev , temp_iter, hydr_prev,&
                    hydr_curr, dry_prev  , dry_curr  , varc_curr, veresi)
!
! ----- Neumann loads vector (residuals)
!
        call asasve(veresi, nume_dof, typres, varesi)
        call ascova('D', varesi, bidon, 'INST', rbid,&
                    typres, cnresi)
        call jeveuo(cnresi(1:19)//'.VALE', 'L', vr=v_cnresi)
!
! --- BT LAMBDA - CALCUL ET ASSEMBLAGE
!
        call vethbt(model, lload_name, lload_info, cara_elem, mate,&
                    temp_prev, vebtla)
        call asasve(vebtla, nume_dof, typres, vabtla)
        call ascova('D', vabtla, bidon, 'INST', rbid,&
                    typres, cnvabt)
        call jeveuo(cnvabt(1:19)//'.VALE', 'L', vr=v_cnvabt)
!
! --- B . TEMPERATURE - CALCUL ET ASSEMBLAGE
!
        call vethbu(model, matass, lload_name, lload_info, cara_elem,&
                    mate, temp_prev, vebuem)
        call asasve(vebuem, nume_dof, typres, vabuem)
        call ascova('D', vabuem, bidon, 'INST', rbid,&
                    typres, cnvabu)
        call jeveuo(cnvabu(1:19)//'.VALE', 'L', vr=v_cnvabu)
!
        do k = 1, lonch
            v_cn2mbr(k) = v_vec2nd(k) - v_cnresi(k) + v_cndirp(k) - v_cnvabt(k)- v_cnvabu(k)
        end do
!
! ----- Solve linear system
!
        if (ds_algorom%l_rom) then
            call romAlgoNLSystemSolve(matass, cn2mbr, ds_algorom, chsol)
        else
            call nxreso(matass, maprec, solver, cnchci, cn2mbr,&
                        chsol)
        endif
!
! --- RECOPIE DANS temp_iter DU CHAMP SOLUTION CHSOL
!
        call copisd('CHAMP_GD', 'V', chsol, temp_iter)
!
    else
!
!=======================================================================
!  INITIALISATION POUR LE PREMIER PAS, CALCUL TRANSITOIRE, PAS COURANT
!=======================================================================
!
        do k = 1, lonch
            v_cn2mbr(k) = v_vec2ni(k) + v_cndirp(k)
        end do
!
! ----- Solve linear system
!
        if (ds_algorom%l_rom) then
            call copisd('CHAMP_GD', 'V', temp_prev, chsol)
            call romAlgoNLSystemSolve(matass, cn2mbr, ds_algorom, chsol)
        else
            call nxreso(matass, maprec, solver, cnchci, cn2mbr,&
                        chsol)
        endif

!
! --- RECOPIE DANS temp_iter DU CHAMP SOLUTION CHSOL
!
        call copisd('CHAMP_GD', 'V', chsol, temp_iter)
!
    endif
!
    call jedema()
end subroutine
