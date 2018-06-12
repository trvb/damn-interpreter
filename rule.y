%{
   /* déclarations système */
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex(void);
    void yyerror (char const *s) {
        fprintf (stderr, "%s\n", s);
    }

    int registers[4];

    int memory[5000];
    char *assembly[5000];

    enum e_opcode
    {
        PLUS, /* CPU implemented in the OP code _order_*/
        SUBS,
        MULT,
        LSHT,
        RSHT,
        EQUL,
        DIFF,
        INFR,
        INFE,
        SUPR,
        SUPE,
        COPY,
        READ,
        SAVE,
        MOVE,
        JCVD,
        JUMP,

        DIVX, /* Others, not CPU implemented */
        SHOW
    };

    union u_ptr_or_imm
    {
        int *ptr;
        int imm;
    };

    union u_param_src
    {
        char reg;
        short addr;
        short imm;
    };

    enum e_param_type
    {
        PTR,
        IMM,
        REG
    };
    
    struct s_instruct
    {
        enum e_opcode op;

        /* Param1 */
        enum  e_param_type p1type;
        union u_ptr_or_imm param1;

        /* Assembly param1 */
        union u_param_src param1_src;

        /* Param 2 */
        enum  e_param_type p2type;
        union u_ptr_or_imm param2;

        /* Assembly param2 */
        union u_param_src param2_src;
    };

    typedef struct s_instruct t_instruct;

    t_instruct instrs[5000];
    int instr_pointer=0;

    void register_instructions_2regs(enum e_opcode op, char r1, char r2)
    {
        int *p1 = &registers[r1];
        int *p2 = &registers[r2];

        union u_ptr_or_imm mp1;
        mp1.ptr = p1;
        union u_ptr_or_imm mp2;
        mp2.ptr = p2;

        union u_param_src srcp1;
        srcp1.reg = r1;
        union u_param_src srcp2;
        srcp2.reg = r2;

        t_instruct an_instruction = {op,REG,mp1,srcp1,REG,mp2,srcp2};

        instrs[instr_pointer++] = an_instruction;       
    }

    void register_instructions_reg_addr(enum e_opcode op, char r1, int addr)
    {
        int *p1 = &registers[r1];
        int *p2 = &memory[addr];

        union u_ptr_or_imm mp1;
        mp1.ptr = p1;
        union u_ptr_or_imm mp2;
        mp2.ptr = p2;

        union u_param_src srcp1;
        srcp1.reg = r1;
        union u_param_src srcp2;
        srcp2.addr = addr;

        t_instruct an_instruction = {op,REG,mp1,srcp1,PTR,mp2,srcp2};

        instrs[instr_pointer++] = an_instruction;      
    }

    void register_instructions_reg_imm(enum e_opcode op, char r1, int imm)
    {
        int *p1 = &registers[r1];

        union u_ptr_or_imm mp1;
        mp1.ptr = p1;
        union u_ptr_or_imm mp2;
        mp2.imm = imm;

        union u_param_src srcp1;
        srcp1.reg = r1;
        union u_param_src srcp2;
        srcp2.imm = imm;

        t_instruct an_instruction = {op,REG,mp1,srcp1,IMM,mp2,srcp2};

        instrs[instr_pointer++] = an_instruction;      
    }

    // /* Vieux code, plus utilisé */
    // void register_instruction_ptr(enum e_opcode op, int* p1, int* p2)
    // {
    //     union u_ptr_or_imm mp2;
    //     mp2.ptr = p2;
    //     t_instruct aninstruction = {op,p1,PTR,mp2};

    //     instrs[instr_pointer++] = aninstruction;
    // }

    // /* Bis */
    // void register_instruction_imm(enum e_opcode op, int* p1, int p2)
    // {
    //     union u_ptr_or_imm mp2;
    //     mp2.imm = p2;
    //     t_instruct aninstruction = {op,p1,IMM,mp2};
    //     instrs[instr_pointer++] = aninstruction;
    // }

    void dump_assembly()
    {
        printf("Parsed assembly (%d instructions):\n", instr_pointer);
        printf("NUMBER\tOP_CODE\tPARAM1\t\tPARAM2\n");
        for(int i=0; i<instr_pointer; i++)
        {
            t_instruct an_instr = instrs[i];
            
            if(an_instr.p2type == IMM)
                printf("%d\t%d\t%p\t%d\n", i, an_instr.op, an_instr.param1, an_instr.param2);
            else
                printf("%d\t%d\t%p\t%p\n", i, an_instr.op, an_instr.param1, an_instr.param2);  
        }
    }

    void output_param(char *buf, enum e_param_type ptype, union u_param_src src)
    {
        if(ptype == REG)
            sprintf(buf, "%1x", src.reg);
        else if(ptype == IMM)
            sprintf(buf, "%04x", src.imm);
        else if(ptype == PTR)
            sprintf(buf, "%04x", src.addr);
    }

    void load_assembly()
    {
        for(int i=0; i<instr_pointer; i++)
        {
            char *asm_line = malloc(sizeof(char) * 10);

            t_instruct an_instr = instrs[i];
            sprintf(asm_line, "0%1x0", an_instr.op);
            if(an_instr.p2type == REG)
            {
                output_param(asm_line + strlen(asm_line), an_instr.p1type, an_instr.param1_src);
                sprintf(asm_line + strlen(asm_line), "000");
                output_param(asm_line + strlen(asm_line), an_instr.p2type, an_instr.param2_src);
            }
            else
            {
                output_param(asm_line + strlen(asm_line), an_instr.p1type, an_instr.param1_src);
                output_param(asm_line + strlen(asm_line), an_instr.p2type, an_instr.param2_src);
            }

            assembly[i] = asm_line;
        }
    }

    void output_assembly()
    {
        for(int i=0; i<instr_pointer; i++)
            printf("%s\n", assembly[i]);       
    }

    void dump_memory()
    {
        printf("\nRegisters:\n");
        for(int i=0; i<4; i++)
            printf("%p R%d -> %d\n", &registers[i], i, registers[i]);

        printf("\nMemory:\n");
        for(int i=0; i<10; i++)
            printf("%p [%d] -> %d\n", &memory[i], i, memory[i]);
    }

    void execute()
    {
        printf("\nExecuting code ...\n");
        int ord=0;

        do {
            t_instruct inst = instrs[ord];

            switch(inst.op) {
                case PLUS:
                    *(inst.param1.ptr) += *(inst.param2.ptr); 
                    break;
                case SUBS:
                    *(inst.param1.ptr) -= *(inst.param2.ptr); 
                    break;
                case MULT:
                    *(inst.param1.ptr) *= *(inst.param2.ptr); 
                    break;
                case DIVX:
                    *(inst.param1.ptr) /= *(inst.param2.ptr); 
                    break;
                case READ:
                    *(inst.param1.ptr) = *(inst.param2.ptr); 
                    break;
                case SAVE:
                    *(inst.param2.ptr) = *(inst.param1.ptr);
                    // printf("Saving %d into %p -> %d\n", *(inst.param1.ptr), inst.param2.ptr, *inst.param2.ptr);
                    break;
                case MOVE:
                    *(inst.param1.ptr) = inst.param2.imm;
                    // printf("Moving %d into %p -> %d\n", inst.param2.imm, inst.param1.ptr, *inst.param1.ptr);
                    break;
                case COPY:
                        *(inst.param1.ptr) = *(inst.param2.ptr); 
                case JUMP:
                    ord = inst.param2.imm; 
                    break;
                case JCVD:
                    printf("JCVD comp res: %d\n", *(inst.param1.ptr));
                    ord = (*(inst.param1.ptr) == 0) ? ord: inst.param2.imm; 
                    break;
                case EQUL:
                    *(inst.param1.ptr) = !(*(inst.param1.ptr) == *(inst.param2.ptr)); 
                    break;
                case DIFF:
                    *(inst.param1.ptr) = !(*(inst.param1.ptr) != *(inst.param2.ptr)); 
                    break;
                case INFR:
                    *(inst.param1.ptr) = !(*(inst.param1.ptr) < *(inst.param2.ptr)); 
                    break;
                case INFE:
                    *(inst.param1.ptr) = !(*(inst.param1.ptr) <= *(inst.param2.ptr)); 
                    break;
                case SUPR:
                    *(inst.param1.ptr) = !(*(inst.param1.ptr) > *(inst.param2.ptr)); 
                    break;
                case SUPE:
                    *(inst.param1.ptr) = !(*(inst.param1.ptr) >= *(inst.param2.ptr)); 
                    break;
                case SHOW:
                    printf("SHOWtime: %d\n", *(inst.param1.ptr));
            }

            ord++;

        } while(ord < instr_pointer);
    }
%}

/* Déclaration des jetons */
%token tPLUS;
%token tSUBS;
%token tMULT;
%token tDIVX;
%token tCOPY;
%token tREAD;
%token tSAVE;
%token tMOVE;
%token tJUMP;
%token tJCVD;
%token tEQUL;
%token tDIFF;
%token tINFR;
%token tINFE;
%token tSUPR;
%token tSUPE;
%token tINT;
%token tCHAR;
%token tREG;
%token tIDSEP;
%token tSHOW;

/* Déclaration des types parser/compiler */
%union { 
    int integer;
    char character;
};

/* Déclarations de types */
%type <integer> tINT;
%type <character> tCHAR;
%type <integer> tREG;
%%
main: execs { 
        printf("Done reading\n");
    };

execs :
    exec execs
    | exec
    ;

exec: tMOVE tREG tIDSEP tINT {
        //registers[$2] = $2;
        //register_instruction_imm(MOVE,&registers[$2],$4);
        register_instructions_reg_imm(MOVE, $2, $4);
    }
    | tCOPY tREG tIDSEP tREG {
        register_instructions_2regs(COPY, $2, $4);
    }
    | tPLUS tREG tIDSEP tREG {
        // registers[$2] += registers[$2]
        // register_instruction_ptr(PLUS,&registers[$2],&registers[$4]);
        register_instructions_2regs(PLUS, $2, $4);
    }
    | tSUBS tREG tIDSEP tREG {
        // registers[$2] -= registers[$2]
        // register_instruction_ptr(SUBS,&registers[$2],&registers[$4]);
        register_instructions_2regs(SUBS, $2, $4);
    }
    | tMULT tREG tIDSEP tREG {
        // registers[$2] *= registers[$2]
        // register_instruction_ptr(MULT,&registers[$2],&registers[$4]);
        register_instructions_2regs(MULT, $2, $4);
    }
    | tDIVX tREG tIDSEP tREG {
        // registers[$2] /= registers[$2]
        // register_instruction_ptr(DIVX,&registers[$2],&registers[$4]);
        // pas implémenté :)
    }
    | tREAD tREG tIDSEP tINT {
        // registers[$2] = memory[$2]
        // register_instruction_ptr(READ,&registers[$2],&memory[$4]);
        register_instructions_reg_addr(READ, $2, $4);
    }
    | tSAVE tREG tIDSEP tINT {
        // memory[$2] = registers[$2]
        // register_instruction_ptr(SAVE,&memory[$4],&registers[$2]);
        register_instructions_reg_addr(SAVE, $2, $4);
    }
    | tJUMP tINT {
        // memory[$2] += memory[$2]
        // register_instruction_imm(MOVE,NULL,$2);
        register_instructions_reg_imm(JUMP, 0, $2);
    }
    | tSHOW tREG {
        // register_instruction_ptr(SHOW,&registers[$2],NULL);
        register_instructions_2regs(SHOW, $2, $2);
    }
    | tJCVD tREG tIDSEP tINT {
        // register_instruction_imm(JCVD,&registers[$2],$4);    
        register_instructions_reg_imm(JCVD, $2, $4);
    }
    | tEQUL tREG tIDSEP tREG {
        // register_instruction_ptr(EQUL,&registers[$2],&registers[$4]);
        register_instructions_2regs(EQUL, $2, $4);
    }
    | tDIFF tREG tIDSEP tREG {
        // register_instruction_ptr(DIFF,&registers[$2],&registers[$4]);
        register_instructions_2regs(DIFF, $2, $4); 
    }
    | tINFR tREG tIDSEP tREG {
        // register_instruction_ptr(INFR,&registers[$2],&registers[$4]);
        register_instructions_2regs(INFR, $2, $4);
    }
    | tINFE tREG tIDSEP tREG {
        // register_instruction_ptr(INFE,&registers[$2],&registers[$4]);
        register_instructions_2regs(INFE, $2, $4);
    }
    | tSUPR tREG tIDSEP tREG {
        // register_instruction_ptr(SUPR,&registers[$2],&registers[$4]); 
        register_instructions_2regs(SUPR, $2, $4);   
    }
    | tSUPE tREG tIDSEP tREG {
        // register_instruction_ptr(SUPE,&registers[$2],&registers[$4]);
        register_instructions_2regs(SUPE, $2, $4);
    };

%%

int main(int argc, char ** argv) {
    if(argc < 2)
    {
        printf("Usage: %s asm|exc\n", argv[0]);
        exit(0);
    }

    yyparse(); /* parses input code from compiler */

    load_assembly(); /* loads machine assembly from code structure */

    if(strcmp(argv[1], "asm") == 0)
        output_assembly();
    else
    {
        dump_assembly();
        execute();
        dump_memory();
    }
}