subroutine nmresi(noma  , mate   , numedd  , sdnume  , fonact,&
                  sddyna, ds_conv, ds_print, ds_contact,&
                  matass, numins , eta     , comref  , valinc,&
                  solalg, veasse , measse  , ds_inout, ds_algorom,&
                  vresi , vchar)
!
use NonLin_Datastructure_type
use Rom_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/r8vide.h"
#include "asterfort/dismoi.h"
#include "asterfort/infdbg.h"
#include "asterfort/isfonc.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mmconv.h"
#include "asterfort/ndiner.h"
#include "asterfort/ndynlo.h"
#include "asterfort/nmchex.h"
#include "asterfort/nmequi.h"
#include "asterfort/nmigno.h"
#include "asterfort/nmimre.h"
#include "asterfort/nmimre_dof.h"
#include "asterfort/GetResi.h"
#include "asterfort/nmpcin.h"
#include "asterfort/nmrede.h"
#include "asterfort/nmvcmx.h"
#include "asterfort/rescmp.h"
#include "asterfort/romAlgoNLMecaResidual.h"
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=8) :: noma
    character(len=24) :: numedd
    type(NL_DS_Contact), intent(in) :: ds_contact
    type(NL_DS_Conv), intent(inout) :: ds_conv
    type(NL_DS_Print), intent(inout) :: ds_print
    character(len=24) :: mate
    integer :: numins
    character(len=19) :: sddyna, sdnume
    character(len=19) :: measse(*), veasse(*)
    character(len=19) :: valinc(*), solalg(*)
    character(len=19) :: matass
    character(len=24) :: comref
    integer :: fonact(*)
    real(kind=8) :: eta
    type(NL_DS_InOut), intent(in) :: ds_inout
    real(kind=8), intent(out) :: vchar
    real(kind=8), intent(out) :: vresi
    type(ROM_DS_AlgoPara), intent(in) :: ds_algorom
!
! --------------------------------------------------------------------------------------------------
!
! MECA_NON_LINE - Convergence management
!
! Compute residuals
!
! --------------------------------------------------------------------------------------------------
!
! IN  NOMA   : NOM DU MAILLAGE
! IO  ds_print         : datastructure for printing parameters
! IN  NUMEDD : NUMEROTATION NUME_DDL
! IN  SDNUME : NOM DE LA SD NUMEROTATION
! In  ds_inout         : datastructure for input/output management
! IO  ds_conv          : datastructure for convergence management
! IN  COMREF : VARI_COM REFE
! IN  MATASS : MATRICE DU PREMIER MEMBRE ASSEMBLEE
! IN  NUMINS : NUMERO D'INSTANT
! In  ds_contact       : datastructure for contact management
! In  ds_algorom       : datastructure for ROM parameters
! IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
! IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
! IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
! IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
! IN  ETA    : COEFFICIENT DE PILOTAGE
! Out vresi            : norm of equilibrium residual
! Out vchar            : norm of exterior loads
!
! --------------------------------------------------------------------------------------------------
!
    integer :: jccid=0, jdiri=0, jvcfo=0, jiner=0
    integer :: ifm=0, niv=0
    integer :: neq=0
    character(len=8) :: noddlm=' '
    aster_logical :: ldyna, lstat, lcine, l_cont_cont, l_cont_lac, l_rom
    character(len=19) :: profch=' ', foiner=' '
    character(len=19) :: commoi=' ', depmoi=' '
    character(len=19) :: cndiri=' ', cnbudi=' ', cnvcfo=' ', cnfext=' '
    character(len=19) :: cnvcf1=' ', cnrefe=' ', cnfint=' '
    character(len=19) :: cnfnod=' ', cndipi=' ', cndfdo=' '
    integer :: jfnod=0
    integer :: ieq=0
    aster_logical :: lrefe=.false._1, linit=.false._1, lcmp=.false._1, l_rela=.false._1
    real(kind=8) :: val1=0.d0, val4=0.d0, val5=0.d0
    real(kind=8) :: maxres=0.d0
    integer :: irela=0, imaxi=0, iresi=0, irefe=0, ichar=0, icomp=0
    aster_logical :: lndepl=.false._1, lpilo=.false._1
    real(kind=8) :: resi_glob_rela, resi_glob_maxi
    character(len=16) :: nfrot=' ', ngeom=' '
    character(len=24) :: sdnuco=' '
    integer :: jnuco=0
    real(kind=8) :: vrela, vmaxi, vrefe, vinit, vcomp, vfrot, vgeom
    real(kind=8), pointer :: budi(:) => null()
    real(kind=8), pointer :: dfdo(:) => null()
    real(kind=8), pointer :: dipi(:) => null()
    real(kind=8), pointer :: fext(:) => null()
    real(kind=8), pointer :: fint(:) => null()
    real(kind=8), pointer :: refe(:) => null()
    real(kind=8), pointer :: vcf1(:) => null()
    integer, pointer :: deeq(:) => null()
!
! --------------------------------------------------------------------------------------------------
!
    call jemarq()
    call infdbg('MECA_NON_LINE', ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<MECANONLINE> ... CALCUL DES RESIDUS'
    endif
!
! --- INITIALISATIONS
!
    vrela = 0.d0
    vmaxi = 0.d0
    vrefe = 0.d0
    vchar = 0.d0
    vresi = 0.d0
    vcomp = 0.d0
    vinit = 0.d0
    vfrot = 0.d0
    vgeom = 0.d0
    irela = 0
    imaxi = 0
    irefe = 0
    iresi = 0
    ichar = 0
    icomp = 0
    jccid = 0
    call dismoi('NB_EQUA', numedd, 'NUME_DDL', repi=neq)
!
! --- FONCTIONNALITES ACTIVEES
!
    ldyna = ndynlo(sddyna,'DYNAMIQUE')
    lstat = ndynlo(sddyna,'STATIQUE')
    lrefe = isfonc(fonact,'RESI_REFE')
    lcmp = isfonc(fonact,'RESI_COMP')
    lpilo = isfonc(fonact,'PILOTAGE')
    lcine = isfonc(fonact,'DIRI_CINE')
    l_cont_cont = isfonc(fonact,'CONT_CONTINU')
    l_cont_lac  = isfonc(fonact,'CONT_LAC')
    l_rom = isfonc(fonact,'ROM')
    linit = (numins.eq.1).and.(.not.ds_inout%l_state_init)
!
! --- DECOMPACTION DES VARIABLES CHAPEAUX
!
    call nmchex(valinc, 'VALINC', 'DEPMOI', depmoi)
    call nmchex(valinc, 'VALINC', 'COMMOI', commoi)
    call nmchex(veasse, 'VEASSE', 'CNDIRI', cndiri)
    call nmchex(veasse, 'VEASSE', 'CNBUDI', cnbudi)
    call nmchex(veasse, 'VEASSE', 'CNVCF0', cnvcfo)
    call nmchex(veasse, 'VEASSE', 'CNVCF1', cnvcf1)
    call nmchex(veasse, 'VEASSE', 'CNREFE', cnrefe)
    call nmchex(veasse, 'VEASSE', 'CNFNOD', cnfnod)
    call nmchex(veasse, 'VEASSE', 'CNDIPI', cndipi)
    cndfdo = '&&CNCHAR.DFDO'
!
! --- CALCUL DE LA FORCE DE REFERENCE POUR LA DYNAMIQUE
!
    if (ldyna) then
        foiner = '&&CNPART.CHP1'
        call ndiner(numedd, sddyna, valinc, measse, foiner)
    endif
!
! --- TYPE DE FORMULATION
!
    lndepl = .not.(ndynlo(sddyna,'FORMUL_DEPL').or.lstat)
!
! --- RESULTANTE DES EFFORTS POUR ESTIMATION DE L'EQUILIBRE
!
    call nmequi(eta, fonact, sddyna, veasse,&
                cnfext, cnfint)
!
! --- POINTEUR SUR LES DDLS ELIMINES PAR AFFE_CHAR_CINE
!
    if (lcine) then
        call nmpcin(matass)
        call jeveuo(matass(1:19)//'.CCID', 'L', jccid)
    endif
!
! --- REPERAGE DDL LAGRANGE DE CONTACT
!
    if (l_cont_cont .or. l_cont_lac) then
        sdnuco = sdnume(1:19)//'.NUCO'
        call jeveuo(sdnuco, 'L', jnuco)
    endif
!
! --- ACCES NUMEROTATION DUALISATION DES EQUATIONS
!
    call dismoi('PROF_CHNO', depmoi, 'CHAM_NO', repk=profch)
    call jeveuo(profch(1:19)//'.DEEQ', 'L', vi=deeq)
!
! --- CALCULE LE MAX DES RESIDUS PAR CMP POUR LE RESIDU RESI_COMP_RELA
!
    if (lcmp) then
        call rescmp(cndiri, cnvcfo, cnfext, cnfint, cnfnod,&
                    maxres, noddlm, icomp)
    endif
!
! --- ACCES AUX CHAM_NO
!
    call jeveuo(cnfint(1:19)//'.VALE', 'L', vr=fint)
    call jeveuo(cndiri(1:19)//'.VALE', 'L', jdiri)
    call jeveuo(cnfext(1:19)//'.VALE', 'L', vr=fext)
    call jeveuo(cnvcfo(1:19)//'.VALE', 'L', jvcfo)
    call jeveuo(cnbudi(1:19)//'.VALE', 'L', vr=budi)
    call jeveuo(cndfdo(1:19)//'.VALE', 'L', vr=dfdo)
    if (lpilo) then
        call jeveuo(cndipi(1:19)//'.VALE', 'L', vr=dipi)
    endif
    if (ldyna) then
        call jeveuo(foiner(1:19)//'.VALE', 'L', jiner)
    endif
    if (linit) then
        call jeveuo(cnvcf1(1:19)//'.VALE', 'L', vr=vcf1)
    endif
    if (lrefe) then
        call jeveuo(cnrefe(1:19)//'.VALE', 'L', vr=refe)
    endif
    if (lcine) then
        call jeveuo(cnfnod(1:19)//'.VALE', 'L', jfnod)
    endif
!
! --- CALCUL DES FORCES POUR MISE A L'ECHELLE (DENOMINATEUR)
!
    call nmrede(sdnume, fonact, sddyna, matass,&
                veasse, neq, foiner, cnfext, cnfint,&
                vchar, ichar)
!
! --- CALCUL DES RESIDUS
!
    do ieq = 1, neq
!
! ----- SI SCHEMA NON EN DEPLACEMENT: ON IGNORE LA VALEUR DU RESIDU
!
        if (nmigno(jdiri ,lndepl,ieq)) then
            goto 20
        endif
!
! ----- SI CHARGEMENT CINEMATIQUE: ON IGNORE LA VALEUR DU RESIDU
!
        if (lcine) then
            if (zi(jccid+ieq-1) .eq. 1) then
                goto 20
            endif
        endif
!
! ----- SI LAGRANGIEN DE CONTACT/FROT: ON IGNORE LA VALEUR DU RESIDU
!
        if (l_cont_cont .or. l_cont_lac) then
            if (zi(jnuco+ieq-1) .eq. 1) then
                goto 20
            endif
        endif
!
! --- CALCUL DU RESIDU A PROPREMENT PARLER
!
        if (lpilo) then
            val1 = abs(fint(ieq)+zr(jdiri+ieq-1)+budi(ieq) -fext(ieq)-dfdo(1+ieq-1)-eta*dipi(ieq))
        else
            val1 = abs( fint(ieq)+zr(jdiri+ieq-1)+budi(ieq) -fext(ieq)-dfdo(1+ieq-1) )
        endif
!
! --- VRESI: MAX RESIDU D'EQUILIBRE
!
        if (vresi .le. val1) then
            vresi = val1
            iresi = ieq
        endif
!
! --- SI CONVERGENCE EN CONTRAINTE ACTIVE
!
        if (lrefe) then
            if (deeq(2*ieq) .gt. 0) then
                val4 = abs(fint(ieq)+zr(jdiri+ieq-1)+budi(ieq) -fext(ieq)-dfdo(1+ieq-1))/&
                       refe(ieq)
                if (vrefe .le. val4) then
                    vrefe = val4
                    irefe = ieq
                endif
            endif
        endif
!
! --- SI TEST CONTRAINTES INITIALES
!
        if (linit) then
            val5 = abs(vcf1(ieq))
            if (vinit .le. val5) then
                vinit = val5
            endif
        endif
 20     continue
    end do
!
! - Evaluate residuals in applying HYPER-REDUCTION
!
    if (l_rom) then
        call romAlgoNLMecaResidual(fint, fext, ds_algorom, vresi)
    endif
!
! --- SYNTHESE DES RESULTATS
!
    vmaxi = vresi
    imaxi = iresi
    if (vchar .gt. 0.d0) then
        vrela = vresi/vchar
        irela = iresi
    else
        vrela = -1.d0
    endif
!
    if (lcmp) then
        vcomp = maxres
    endif
!
! --- RESIDUS SPECIFIQUES POUR NEWTON GENERALISE
!
    if (l_cont_cont .or. l_cont_lac) then
        call mmconv(noma , ds_contact, valinc, solalg, vfrot,&
                    nfrot, vgeom     , ngeom)
    endif
!
! - Save informations about residuals into convergence datastructure
!
    call nmimre_dof(numedd, ds_conv, vrela, vmaxi, vrefe, &
                    vcomp , vfrot  , vgeom, irela, imaxi, &
                    irefe , noddlm , icomp, nfrot, ngeom)
!
! - Set value of residuals informations in convergence table
!
    call nmimre(ds_conv, ds_print)
!
! - Get convergence parmeters
!
    call GetResi(ds_conv, type = 'RESI_GLOB_RELA' , user_para_ = resi_glob_rela,&
                 l_resi_test_ = l_rela)
    call GetResi(ds_conv, type = 'RESI_GLOB_MAXI' , user_para_ = resi_glob_maxi)
!
! --- VERIFICATION QUE LES VARIABLES DE COMMANDE INITIALES CONDUISENT
! --- A DES FORCES NODALES NULLES
!
    if (linit) then
        if (l_rela) then
            if (vchar .gt. resi_glob_rela) then
                vinit = vinit/vchar
                if (vinit .gt. resi_glob_rela) then
                    call nmvcmx(mate, noma, comref, commoi)
                endif
            endif
        else
            if (vinit .gt. resi_glob_maxi) then
                call nmvcmx(mate, noma, comref, commoi)
            endif
        endif
    endif
!
    call jedema()
end subroutine
