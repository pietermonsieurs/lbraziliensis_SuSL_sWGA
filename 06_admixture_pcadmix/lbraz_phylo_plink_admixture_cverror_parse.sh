## the plink admixture has been run for different K-values and different
## random seeds to check for consistency and convergence of the results in order
## to comply with a reviewer comment. parsing should now be done over the different
## k-values and seed values to make standard errors on the CV

cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/

echo "data_set\tK_value\tseed\tCV_error" > lbraz_admixture_CV_values_all_seeds.txt

for type in phylo.SuSL phylo.sWGA_baits phylo.sWGA_digest; do
  for seed in {1..10}; do
    for K in {2..20}; do
      grep -h "CV error" ${type}__seed${seed}/${type}.filtered_stringent.renamed2.fraction0.95.lbraz.snps.complete.ldpruned.K${K}.log \
      | awk -v t="${type}" -v k="${K}" -v s="${seed}" '{print t "\t" k "\t" s "\t" $4}' \
      >> lbraz_admixture_CV_values_all_seeds.txt
    done
  done
done