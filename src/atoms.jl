export transpose, ctranspose, kl_div, lambda_min, lambda_max, log_det, norm, quad_form, quad_over_lin, abs, pos, square

# cvxpy atoms
#['abs', 'affine', 'atom', 'elementwise', 'geo_mean', 'inv_pos', 'lambda_max', 'lambda_min', 'log', 'max', 'min', 'neg', 'nonlinear', 'norm', 'norm1', 'norm2', 'normInf', 'normNuc', 'norm_inf', 'norm_nuc', 'pos', 'quad_form', 'quad_over_lin', 'sigma_max', 'sqrt', 'square', 'sum', 'vstack']

# slicing atoms
# get the right names for these
transpose(x::AbstractCvxExpr) = CvxExpr(:transpose,[x],x.vexity,x.sign,reverse(x.size))
ctranspose(x::AbstractCvxExpr) = transpose(x)
getindex(x::AbstractCvxExpr,index...) = CvxExpr(:index,[x,index...],x.vexity,x.sign,size)
# this breaks the syntax [x,y] to concatenate lists of expressions as in arguments to atoms 
# extend to *args
# vcat(args::Array{AbstractCvxExpr}) = CvxExpr(:vstack,args,promote_vexity([a.vexity for a in args]...),promote_sign([a.sign for a in args]...),sizes...)

### matrix to scalar atoms
function kl_div(x::AbstractCvxExpr,y::AbstractCvxExpr)
	if (length(x.size) == 0 || maximum(x.size) <= 1) && (length(y.size) == 0 || maximum(y.size) <= 1)
		return CvxExpr(:kl_div,[x,y],:convex,:pos,(1,1))
	else
		error("kl_div only implemented for scalar arguments")
	end
end
function lambda_min(x::AbstractCvxExpr)
	if x.vexity in (:constant, :linear)
		return CvxExpr(:lambda_min,[x],:concave,:any,(1,1))
	else
		error("lambda_min(x) not DCP compliant for x = $x")
	end
end
function lambda_max(x::AbstractCvxExpr)
	if x.vexity in (:constant, :linear)
		return CvxExpr(:lambda_max,[x],:convex,:any,(1,1))
	else
		error("lambda_max(x) not DCP compliant for x = $x")
	end
end
function log_det(x::AbstractCvxExpr)
	if x.vexity in (:constant, :linear)
		return CvxExpr(:log_det,[x],:concave,:any,(1,1))
	else
		error("log_det(x) not DCP compliant for x = $x")
	end
end
# conversion of p from symbol to string if necessary will be done automatically
function norm(x::AbstractCvxExpr, p = 2)
	if x.vexity == :constant
		return CvxExpr(:norm,[x,p],:constant,:pos,(1,1))
	elseif x.vexity == :linear
		return CvxExpr(:norm,[x,p],:convex,:pos,(1,1))	
	elseif x.vexity == :convex && x.sign == :pos
		return CvxExpr(:norm,[x,p],:convex,:pos,(1,1))	
	elseif x.vexity == :concave && x.sign == :neg
		return CvxExpr(:norm,[x,p],:convex,:pos,(1,1))		
	else
		error("norm(x) is not DCP compliant when x has curvature $(x.vexity) and sign $(x.sign)")
	end
end
# better dcp checking needed...
function quad_form(x::AbstractCvxExpr, P::AbstractCvxExpr)
	if x.vexity == :constant
		return CvxExpr(:quad_form,[x,P],P.vexity,:any,(1,1))
	elseif P.vexity == :constant
		return CvxExpr(:quad_form,[x,P],:convex,:pos,(1,1))		
	else
		error("at least one argument to quad_form must be constant")
	end
end
quad_form(x::AbstractCvxExpr,y) = quad_form(x,convert(CvxExpr,y))
quad_form(x,y::AbstractCvxExpr) = quad_form(convert(CvxExpr,x),y)

# better dcp checking needed...
function quad_over_lin(x::AbstractCvxExpr, y::AbstractCvxExpr)
	if y.size in Set((),(1),(1,1)) && y.sign == :pos && y.vexity in (:constant, :linear, :concave)
		size = y.size
	else
		error("y must by a positive scalar with constant, linear, or concave curvature in quad_over_lin(x,y); got $y")
	end
	if x.vexity == :constant
		return CvxExpr(:quad_over_lin,[x,y],:convex,:pos,size)
	elseif x.vexity == :linear
		return CvxExpr(:quad_over_lin,[x,y],:convex,:pos,size)	
	elseif x.vexity == :convex && x.sign == :pos
		return CvxExpr(:quad_over_lin,[x,P],:convex,:pos,size)	
	elseif x.vexity == :concave && x.sign == :neg
		return CvxExpr(:quad_over_lin,[x,P],:convex,:pos,size)		
	else
		error("quad_over_lin(x,y) is not DCP compliant when x has curvature $(x.vexity) and sign $(x.sign)")
	end
end
### matrix to matrix
#max(*args)
#min(*args)

### elementwise
import Base.abs
function abs(x::AbstractCvxExpr)
	if x.vexity == :constant
		return CvxExpr(:abs,[x],:constant,:pos,x.size)
	elseif x.vexity == :linear
		if x.sign == :pos
			return CvxExpr(:abs,[x],:linear,:pos,x.size)
		elseif x.sign == :neg
			return CvxExpr(:abs,[x],:linear,:pos,x.size)	
		else
			return CvxExpr(:abs,[x],:convex,:pos,x.size)	
		end
	elseif x.vexity == :convex && x.sign == :pos
		return CvxExpr(:abs,[x],:convex,:pos,x.size)	
	elseif x.vexity == :concave && x.sign == :neg
		return CvxExpr(:abs,[x],:convex,:pos,x.size)		
	else
		error("abs(x) is not DCP compliant when x has curvature $(x.vexity) and sign $(x.sign)")
	end
end
# entr # entropy
# inv_pos
# log
function sum(x::AbstractCvxExpr)
	return CvxExpr(:sum,[x],x.vexity,x.sign,(1,1))
end
function sum(args::AbstractCvxExpr...)
	return CvxExpr(:sum,args,promote_vexity(args),promote_sign(args),promote_size(args))
end
function pos(x::AbstractCvxExpr)
	if x.vexity == :constant
		return CvxExpr(:pos,[x],:constant,:pos,x.size)
	elseif x.sign == :neg || x.sign == :zero
		return CvxExpr(:pos,[x],:constant,:zero,x.size)	
	elseif x.vexity == :linear
		if x.sign == :pos
			return CvxExpr(:pos,[x],:linear,:pos,x.size)
		else
			return CvxExpr(:pos,[x],:convex,:pos,x.size)	
		end
	elseif x.vexity == :convex
		return CvxExpr(:pos,[x],:convex,:pos,x.size)		
	else
		error("pos(x) is not DCP compliant when x has curvature $(x.vexity) and sign $(x.sign)")
	end
end
	# sqrt
function square(x::AbstractCvxExpr)
	if x.vexity == :constant
		return CvxExpr(:square,[x],:constant,:pos,x.size)
	elseif x.vexity == :linear
		return CvxExpr(:square,[x],:convex,:pos,x.size)
	elseif x.vexity == :convex && ( x.sign == :pos || x.sign == :zero )
		return CvxExpr(:square,[x],:convex,:pos,x.size)	
	elseif x.vexity == :concave && ( x.sign == :neg || x.sign == :zero )
		return CvxExpr(:square,[x],:convex,:pos,x.size)		
	else
		error("square(x) is not DCP compliant when x has curvature $(x.vexity) and sign $(x.sign)")
	end
end