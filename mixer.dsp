import("stdfaust.lib");//rubare codici dagli altri
ctrlgroup(x) = vgroup("[01]", x);
fader = ctrlgroup(vslider("[02] VOL", -70., -70., +12., 0.1)) : ba.db2linear : si.smoo;
panpot = ctrlgroup((vslider("[01] PAN [style:knob]", 0.0, -90.0, 90.0, 0.1))+90)/180 : si.smoo ; 
vmeter(x) = attach(x, envelop(x) : vbargraph("[99][unit:dB]", -70, +5))
with {
    envelop = abs : max ~ -(1.0/ma.SR) : max(ba.db2linear(-70)) : ba.linear2db;
};
pmode = nentry("[01] pan mode [style:menu{'Linear':0; 'exponential':1}]", 0, 0, 1, 1) : int;
process = _ <:
             * (1-panpot), * (sqrt(1-panpot)),//left lineare, left quadratico
             * (panpot), * (sqrt(panpot)) :// right linare, right quadratico
             ba.selectn(2,pmode), //selettore sinistro
             ba.selectn(2,pmode) : // selettore destro
             *(fader), *(fader) : vmeter, vmeter;

//attach interrompe il flusso di un segnale, ma non chiudendolo, processandolo (envelop) (x,y) x*1,y*0
//vmeter ci da i valori dell'onda, ma la parte negativa viene resa positiva
//abs da il valore assoluto
//max è il valore massimo che può essere espresso
//SR significa Sample Rate
//(1.0/ma.SR) esprime la divisione di uno per la frequenza di campionamento
//db2linear converte i dB in valori da 0 a 1
//tutti i valori di process a envelop vanno a vbargraph che ce li a in forma visiva
//si.smoo è un interpolatore che serve per non sentire suoni fastidiosi nello spostamento del panpot

